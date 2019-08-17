# Info about a potential chess move
class Move
  PIECES = Hash.new(Pawn).merge!('K' => King, 'Q' => Queen, 'R' => Rook,
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
    instance_variable_set(@piece_type ? :@promotee : :@piece_type,
                          PIECES[char.upcase])
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

  private

  # Returns hash whose keys are possible pieces with extra changes as values
  def possible_moving_pieces(board)
    board.each_with_object({}) do |poss_piece, all_poss|
      next unless poss_piece != @piece && poss_piece.is_a?(@piece_type) &&
                  poss_piece.colour == @colour &&
                  (conds = poss_piece.conds_of_move(@target, true)) &&
                  (extra_changes = board.satisfied?(@colour, conds, @last_move))

      all_poss[poss_piece] = @piece ? {} : extra_changes
      # Ignore changes if we've already identified the piece - they won't happen
    end
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

    return ambiguity_grumble if @possibles.length > 1

    make_poss_piece
    eliminate_moves_into_check(@extras, board) # After tests before committing
    make_move(board)
  end

  def eliminate_moves_into_check(piece_n_changes, board)
    piece_n_changes.select! { |piece, _v| move_without_check?(board, piece) }
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
      (@promotee = choose_promotee(board)) until @promotee
    elsif (pawn_target = @extra_changes[:en_passon])
      @taken = board[*pawn_target]
      board[*pawn_target] = nil
    end
    @taken.is_a?(Piece) ? @taken : true
  end

  def choose_promotee(board)
    puts 'What piece do you want to promote to?'
    board[*@target] =
      case gets.strip
      when /[qQ]/
        Queen
      when /[rRcC]/
        return (board[*@target] = Rook.new(@colour, *@target, true))
      when /[bB]/
        Bishop
      when /[nNkK]/
        Knight
      else return false
      end.new(@colour, *@target)
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

  def ambiguity_grumble
    puts "Be more explicit about which #{@piece_type} you want to move."
    false
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
    alg = PIECES.key(@piece) || ''
    alg << disambiguating_origin_data
    alg << 'x' if @taken
    alg << vector_to_algebra(*@target)
    alg << PIECES.key(@promotee) if @promotee
    alg
  end

  # Try rank, else file, else origin
  def disambiguating_origin_data
    return '' if @extras.empty?

    if no_extras_in_row?(0)
      index_to_file(@origin[0])
    elsif no_extras_in_row?(1)
      index_to_rank(@origin[1])
    else vector_to_algebra(*@origin)
    end
  end

  def no_extras_in_row?(dim)
    @extras.none? { |piece, _v| piece.square[dim] == @origin[dim] }
  end

  def vector_to_algebra(rank_i, file_i)
    index_to_file(file_i) << index_to_rank(rank_i)
  end

  def index_to_file(ind)
    (ind + 97).chr
  end

  def index_to_rank(ind)
    (ind + 1).to_s
  end
end
