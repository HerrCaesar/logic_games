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

  def move(colour, hsh, last_move)
    return false if (piece = @board[*hsh[:target]]) && piece.colour == colour

    if hsh[:square]
      move_w_coords(colour, hsh, last_move)
    else move_w_piece(colour, hsh, last_move)
    end
  end

  def check?(colour)
    king = @board.find { |piece| piece.is_a?(King) && piece.colour == colour }
    threatened?(other_colour(colour), king.square)
  end

  def checkmate?
    false
  end

  def stalemate?
    false
  end

  private

  # piece: Pawn, file: nil, rank: nil, target: nil, promotee: nil
  def move_w_coords(colour, hsh, last_move)
    return false unless
      (piece = @board[*hsh[:square]]) &&
      piece.colour == colour &&
      (conds = piece.conds_of_move(hsh[:target])) &&
      (extra_changes = satisfied?(colour, conds, last_move))

    suck_it_n_see(colour, piece, hsh[:square], hsh[:target], extra_changes)
  end

  # piece: Pawn, file: nil, rank: nil, target: nil, promotee: nil
  def move_w_piece(colour, hsh, last_move)
    extra_changes = nil
    piece_type = hsh[:piece] || Pawn
    piece =
      possible_squares(hsh).find do |poss_piece|
        poss_piece.is_a?(piece_type) &&
          poss_piece.colour == colour &&
          (conds = poss_piece.conds_of_move(hsh[:target], true)) &&
          (extra_changes = satisfied?(colour, conds, last_move))
      end
    return general_grumble(piece_type) unless piece

    suck_it_n_see(colour, piece, piece.square, hsh[:target], extra_changes)
  end

  # Test conditions for a move to be legal
  def satisfied?(colour, hsh, last_move = nil)
    off_colour = other_colour(colour)
    satisfied =
      if (empties = hsh[:empty])
        are_empty?(empties) &&
          (hsh[:unthreatened].nil? || can_castle?(off_colour, hsh))
      elsif hsh[:enemy]
        pawn_take_satisfied?(off_colour, hsh, last_move)
      else true
      end
    satisfied ? hsh.slice(:move_rook, :promotion) : false
  end

  def can_castle?(threat_colour, hsh)
    return castle_grumble("'t castle out of check") if @check

    return castle_grumble("'t castle through check") unless
      hsh[:unthreatened].none? { |square| threatened?(threat_colour, square) }

    return castle_grumble('only castle with one of your rooks') unless
      (rook = @board[*hsh[:move_rook[:from]]]) && rook.colour != threat_colour

    !rook.moved || castle_grumble("only castle if your rook hasn't moved")
  end

  def pawn_take_satisfied?(off_colour, hsh, last_move)
    (en_passon_target = conds_of_pawn_capture(off_colour, hsh[:enemy])) &&
      en_passon_target.empty? || last_move == { target: en_passon_target }
  end

  # Make the move, but move back if in check
  def suck_it_n_see(colour, piece, origin, target, extra_changes)
    @board[*origin] = nil
    taken = @board[*target]
    @board[*target] = piece
    piece.square = target
    if check?(colour)
      puts "You can't move there; you'll be in check."
      @board[*target] = taken
      @board[*origin] = piece
      piece.square = origin
      false
    else
      extra_board_changes(colour, extra_changes)
      taken.is_a?(Piece) ? taken : true
    end
  end

  def extra_board_changes(colour, move_rook: nil, promotion: nil)
    if move_rook
      rook = @board[*move_rook[:from]]
      @board[*move_rook[:from]] = nil
      @board[*move_rook[:to]] = rook
      rook.square = move_rook[:to]
    end
    choose_promotee(colour, target) if promotion
  end

  def choose_promotee(colour, target)
    puts 'What piece do you want to promote to?'
    piece_type =
      case gets.strip
      when /[qQ]/
        Queen
      when /[rRcC]/
        return (@board[*target] = Rook.new(colour, target[0], target[1], true))
      when /[bB]/
        Bishop
      when /[nNkK]/
        Knight
      else (return choose_promotee(target))
      end
    @board[*target] = piece_type.new(colour, target[0], target[1])
  end

  # piece: Pawn, file: nil, rank: nil, target: nil, promotee: nil
  def possible_squares(hsh)
    if hsh[:file]
      @board.column(hsh[:file])
    elsif hsh[:rank]
      @board.row(hsh[:rank])
    else @board
    end
  end

  def are_empty?(squares)
    squares.none? { |square| @board[*square] }
  end

  # Test if there's an enemy for a pawn to take (can return en-passon condition)
  def conds_of_pawn_capture(off_colour, (target, e_p_target))
    return false unless target

    return {} if enemy_targeted?(off_colour, target) # {} because merged later

    return pawn_grumble unless e_p_target

    enemy_targeted?(off_colour, e_p_target) ? e_p_target : pawn_grumble
  end

  def threatened?(threat_colour, square)
    @board.any? do |piece|
      piece && piece.colour == threat_colour &&
        (conds = piece.conds_of_move(square, true)) &&
        satisfied?(threat_colour, conds)
    end
  end

  def enemy_targeted?(off_colour, target)
    (piece = @board[*target]) && piece.colour == off_colour
  end

  def general_grumble(piece_type)
    puts "No #{piece_type.to_s.downcase} can move to that square."
    false
  end

  def pawn_grumble
    puts "A pawn can't move diagonally unless it's capturing."
    false
  end

  def castle_grumble(phrase)
    puts "You can" + phrase + '.'
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
