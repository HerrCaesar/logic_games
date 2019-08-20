# Info about a potential chess move
class Move
  PIECE_TYPES = Hash.new(Pawn).merge!('K' => King, 'Q' => Queen, 'R' => Rook,
                                      'B' => Bishop, 'N' => Knight).freeze

  attr_accessor :rank, :file
  attr_reader :origin, :target
  attr_writer :last_move

  def initialize(colour: nil, origin: nil, target: nil, piece_type: nil)
    @colour = colour
    @origin = origin if origin
    @target = target if target
    @piece_type = piece_type if piece_type
    @extras = {}
  end

  def add_piece_type(char)
    instance_variable_set(@target ? :@promotee : :@piece_type,
                          PIECE_TYPES[char.upcase])
    self
  end

  def add_target(rank_i, file_i)
    @origin = @target if @target
    @target = Vector[rank_i, file_i]
    self
  end

  def target_own_piece?(board)
    @taken = board[*@target]
    @taken.colour == @colour if @taken
  end

  def move_w_coords(board)
    return false unless
      (@piece = board[*@origin]) && (@piece_type = @piece.class) &&
      @piece.colour == @colour &&
      (conditions = @piece.conds_of_move(@target)) &&
      (@extra_changes = board.satisfied?(@colour, conditions, @last_move))

    @extras = possible_moving_pieces(board)
    try_moves(board)
  end

  def move_w_piece(board)
    @piece_type ||= Pawn
    @possibles = possible_moving_pieces(board)
    if @possibles.length == 1
      make_poss_piece
    elsif @file && !split_poss(1, @file) || @rank && !split_poss(0, @rank)
      return general_grumble(board)
    end

    try_moves(board)
  end

  def to_move_algebra
    move_alg = check_for_castle || translate_move
    MoveAlgebra.new(value: move_alg)
  end

  # Make the move, but move back if in check
  def move_without_check?(board, piece, follow_through = nil)
    move_piece(board, (origin = piece.square), piece)
    check = board.check?(@colour)
    if follow_through
      return clean_up_after_move(board) unless check

      put_back(board, origin, piece)
      check_grumble
    else
      put_back(board, origin, piece)
      !check
    end
  end

  # Returns hash whose keys are possible pieces with extra changes as values
  def possible_moving_pieces(board, paths = false)
    board.each_with_object(paths ? [] : {}) do |poss_piece, all_poss|
      next unless (result = piece_a_possibility?(board, poss_piece, paths))

      if paths
        all_poss << ((result[:empty] || []) << poss_piece.square)
        # Squares that can be moved to, to block check from this piece
      else all_poss[poss_piece] = @piece ? {} : result
        # Ignore changes if piece already identified - they won't happen
      end
    end
  end

  def vector_to_algebra(vec)
    index_to_file(vec[1]) << index_to_rank(vec[0])
  end

  def move_with_piece_possible?(board, poss_piece, paths = false)
    return false unless
      (conds = poss_piece.conds_of_move(@target, true)) &&
      (extra_changes = board.satisfied?(@colour, conds, @last_move))

    paths ? conds : extra_changes
  end

  private

  # Can piece make move? If so, returns piece's path, else extra board changes
  def piece_a_possibility?(board, poss_piece, paths = false)
    return false unless
      poss_piece != @piece &&
      poss_piece.is_a?(@piece_type || Piece) &&
      poss_piece.colour == @colour &&
      (result = move_with_piece_possible?(board, poss_piece, paths))

    result
  end

  def split_poss(dim, dim_val)
    hsh, @extras = @possibles.partition do |poss_piece, _val|
      poss_piece.square[dim] == dim_val
    end.map(&:to_h)
    return false if hsh.empty?

    @extras.each_key { |k| @extras[k] = {} }
    @possibles = hsh
    hsh.length > 1 ? true : make_poss_piece
  end

  def make_poss_piece
    @piece, @extra_changes = @possibles.to_a[0]
    remove_instance_variable(:@possibles)
    @origin = @piece.square
  end

  def try_moves(board)
    @piece ? try_only_move(board) : investigate_several_moves(board)
  end

  def try_only_move(board)
    eliminate_moves_into_check(@extras, board) # To get algebra when needed
    move_without_check?(board, @piece, @extra_changes)
  end

  def investigate_several_moves(board)
    eliminate_moves_into_check(@possibles, board)
    return general_grumble(board) if @possibles.empty?

    if @possibles.length > 1
      x = user_resolves_ambiguity
      return false unless x
    end

    make_poss_piece
    eliminate_moves_into_check(@extras, board) # After tests before committing
    make_move(board)
  end

  def eliminate_moves_into_check(piece_n_changes, board)
    piece_n_changes.select! { |piece, _v| move_without_check?(board, piece) }
  end

  def make_move(board)
    move_piece(board, @origin, @piece)
    clean_up_after_move(board)
  end

  def move_piece(board, origin, piece, target = @target)
    board[*origin] = nil
    board[*target] = piece
    piece.move(target, 'out')
  end

  def put_back(board, origin, piece)
    board[*@target] = @taken
    board[*origin] = piece
    piece.move(origin, 'back')
  end

  def clean_up_after_move(board)
    if (move_rook = @extra_changes[:move_rook])
      move_piece(board, (orig = move_rook[:from]), board[*orig], move_rook[:to])
    elsif @extra_changes[:promotion]
      promote_pawn(board)
    elsif (pawn_target = @extra_changes[:en_passon])
      @taken = board[*pawn_target]
      board[*pawn_target] = nil
    end
    @taken.is_a?(Piece) ? @taken : true
  end

  def promote_pawn(board)
    (@promotee = choose_promotee) until @promotee
    board[*@target] = if @promotee == Rook
                        @promotee.new(@colour, *@target, true)
                      else @promotee.new(@colour, *@target)
                      end
  end

  def choose_promotee
    puts 'What piece do you want to promote to?'
    case gets.strip
    when /[qQ]/
      Queen
    when /[rRcC]/
      Rook
    when /[bB]/
      Bishop
    when /[nNkK]/
      Knight
    else return false
    end
  end

  def general_grumble(board)
    piece_name = @piece_type.to_s.downcase
    case board.count_pieces(@colour, @piece_type)
    when 0
      puts "You don't have any #{piece_name}s."
    when 1
      puts "Your #{piece_name} can't move to that square."
    else puts "No #{piece_name}s can move to that square."
    end
    false
  end

  def user_resolves_ambiguity
    location, options = ambiguity_resolution_options(pieces = @possibles.keys)
    puts "Specify the #{location} of the #{@piece_type} you want:"
    options.each { |x| print x + ' ' }
    puts
    return false unless (ind = options.index(gets.strip))

    @extras = @possibles
    @possibles = { pieces[ind] => @extras.delete(pieces[ind]) }
  end

  # When user hasn't been specific enough, lets them choose piece from options
  def ambiguity_resolution_options(poss_pieces)
    squares = poss_pieces.map(&:square)
    [{ dim: 1, name: 'file', fun: :index_to_file },
     { dim: 0, name: 'rank', fun: :index_to_rank },
     { dim: 0..1, name: 'square', fun: :vector_to_algebra }].each do |hsh|
       result = only_piece_type_in_subset(squares, hsh)
       return result if result
     end
  end

  def only_piece_type_in_subset(squares, dim: nil, name: nil, fun: nil)
    return unless dim.is_a?(Range) || squares.map { |sq| sq[dim] }.uniq!.nil?

    [name, squares.map { |sq| method(fun).call(sq[dim]) }]
  end

  def check_grumble
    puts "You can't move there; you'll be in check."
    false
  end

  def check_for_castle
    return false unless @piece_type == King && @origin

    case (@origin[1] - @target[1]).abs
    when 3
      '0-0-0'
    when 2
      '0-0'
    end
  end

  def translate_move
    alg = PIECE_TYPES.key(@piece_type).dup || ''
    alg << disambiguating_origin_data
    alg << 'x' if @taken
    alg << vector_to_algebra(@target)
    alg << PIECE_TYPES.key(@promotee) if @promotee
    alg
  end

  # Try rank, else file, else origin
  def disambiguating_origin_data
    return index_to_file(@origin[0]) if @taken && @piece.is_a?(Pawn)

    return '' if @extras.empty?

    if no_extras_in_row?(0)
      index_to_file(@origin[0])
    elsif no_extras_in_row?(1)
      index_to_rank(@origin[1])
    else vector_to_algebra(@origin)
    end
  end

  def no_extras_in_row?(dim)
    @extras.none? { |piece, _v| piece.square[dim] == @origin[dim] }
  end

  def index_to_file(ind)
    (ind + 97).chr
  end

  def index_to_rank(ind)
    (ind + 1).to_s
  end
end
