# Chess board. Knows about chess pieces on it.
class Board
  def initialize
    @board = Matrix.build(8, 8) { nil }
    populate_pawns
    populate_back_rank
  end

  def method_missing(*args, &block)
    @board.send(*args, &block)
  end

  def respond_to_missing?(method)
    super || @board.respond_to?(method)
  end

  def p
    p_top
    (1..7).to_a.reverse!.each do |rank|
      p_rank(rank)
      p_mid_divide
    end
    p_rank(0)
    p_bottom
  end

  def make_move(move)
    return self_target_grumble(move) if move.target_own_piece?(self)

    if move.origin
      move.move_w_coords(self)
    else move.move_w_piece(self)
    end
  end

  def check?(colour)
    king = find_king(colour)
    threatened?(other_colour(colour), king.square)
  end

  def checkmate?(attacking_colour)
    king = find_king((king_colour = other_colour(attacking_colour)))
    paths = check_paths(attacking_colour, king)
    return false unless (@check = paths.any?)

    return just_say_check if
      piece_moveable?(king) ||
      paths.reduce(:&).any? { |sq| threatened?(king_colour, sq, true) }

    puts 'Checkmate'
    true
  end

  def stalemate?(attacking_colour)
    return false if @check || any? do |piece|
      piece && piece.colour == other_colour(attacking_colour) &&
      piece_moveable?(piece)
    end

    puts 'Stalemate'
    true
  end

  # Test conditions for a move to be legal. Pass last_move if en-passon possible
  def satisfied?(colour, conds, last_move = nil)
    off_colour = other_colour(colour)
    satisfied =
      if (empties = conds[:empty])
        are_empty?(empties) &&
          (conds[:unthreatened].nil? || can_castle?(off_colour, conds))
      elsif conds[:enemy]
        pawn_take_satisfied?(off_colour, conds, last_move)
      else true
      end
    satisfied ? conds.slice(:move_rook, :en_passon, :promotion) : false
  end

  def count_pieces(colour, piece_type)
    piece_count = 0
    each do |piece|
      if piece && piece.is_a?(piece_type) && piece.colour == colour
        piece_count += 1
        break if piece_count > 1
      end
    end
    piece_count
  end

  private

  def find_king(colour)
    find { |piece| piece.is_a?(King) && piece.colour == colour }
  end

  def check_paths(attacking_colour, king)
    Move.new(colour: attacking_colour, target: king.square)
        .possible_moving_pieces(self, true)
  end

  def piece_moveable?(piece)
    piece.possible_targets.any? do |target|
      move = Move.new(colour: piece.colour, target: target)
      !move.target_own_piece?(self) &&
        (!piece.is_a?(Pawn) || move.move_with_piece_possible?(self, piece)) &&
        move.move_without_check?(self, piece)
    end
  end

  def just_say_check
    puts 'Check'
    false
  end

  def can_castle?(threat_colour, hsh)
    return castle_grumble("'t castle out of check") if @check

    return castle_grumble("'t castle through check") unless
      hsh[:unthreatened].none? { |square| threatened?(threat_colour, square) }

    rook = @board[*hsh[:move_rook][:from]]
    return castle_grumble(' only castle with a rook') unless
      rook.is_a?(Rook) && rook.colour != threat_colour

    !rook.moved || castle_grumble(" only castle if your rook hasn't moved")
  end

  def pawn_take_satisfied?(off_colour, conds, last_move)
    (required_last_move = conds_of_pawn_capture(off_colour, *conds[:enemy])) &&
      (!required_last_move.is_a?(String) || last_move == required_last_move &&
      conds[:en_passon] = conds[:enemy][1])
  end

  def are_empty?(squares)
    squares.none? { |square| @board[*square] }
  end

  # Test if there's an enemy for a pawn to take (can return en-passon condition)
  def conds_of_pawn_capture(off_colour, target, e_p_target = nil)
    return false unless target

    return {} if enemy_targeted?(off_colour, target) # {} because merged later

    return false unless # Not sure #pawn_grumble can work...
      e_p_target && enemy_targeted?(off_colour, e_p_target)

    Move.new(target: e_p_target).to_move_algebra
  end

  def threatened?(threat_colour, square, checkmate_test = false)
    any? do |piece|
      piece && piece.colour == threat_colour &&
        (!checkmate_test || !piece.is_a?(King)) &&
        (conds = piece.conds_of_move(square, true)) &&
        satisfied?(threat_colour, conds)
    end
  end

  def enemy_targeted?(off_colour, target)
    (piece = @board[*target]) && piece.colour == off_colour
  end

  # def pawn_grumble
  #   puts "A pawn can't move diagonally unless it's capturing."
  #   false
  # end

  def self_target_grumble(move)
    puts "You can't move to #{move.vector_to_algebra(move.target)}; your "\
      "#{@board[*move.target].class} is there."
  end

  def castle_grumble(phrase)
    puts 'You can' + phrase + '.'
    false
  end

  def populate_pawns
    [[1, 'w'], [6, 'b']].each do |(rank, colour)|
      8.times { |file| @board[rank, file] = Pawn.new(colour, rank, file) }
    end
  end

  def populate_back_rank
    [[0, 'w'], [7, 'b']].each do |(rank, colour)|
      [0, 7].each { |file| @board[rank, file] = Rook.new(colour, rank, file) }
      [1, 6].each { |file| @board[rank, file] = Knight.new(colour, rank, file) }
      [2, 5].each { |file| @board[rank, file] = Bishop.new(colour, rank, file) }
      @board[rank, 3] = Queen.new(colour, rank)
      @board[rank, 4] = King.new(colour, rank)
    end
  end

  def other_colour(colour)
    colour == 'w' ? 'b' : 'w'
  end

  def p_top
    print '  ╔═══'
    7.times { print '╤═══' }
    puts '╗'
  end

  def p_rank(rank)
    print "#{1 + rank} ║"
    8.times { |file| print(@board[rank, file].to_s.center(3) + '|') }
  end

  def p_mid_divide
    print "\b║\n  ╟───"
    7.times { print '┼───' }
    puts '╢'
  end

  def p_bottom
    print "\b║\n  ╚═══"
    7.times { print '╧═══' }
    puts '╝'
    puts '    a   b   c   d   e   f   g   h'
  end
end
