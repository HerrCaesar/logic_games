require 'matrix'
require_relative 'piece.rb'

# Chess board. Knows about chess peices on it.
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

  def move(colour, hsh)
    return false if (piece = @board[hsh[:target]]) && piece.colour == colour

    move_hash[:square] ? move_w_coords(colour, hsh) : move_w_piece(colour, hsh)
  end

  private

  def move_w_coords(square: nil, target: nil, _promotee: nil)
    return false unless (piece = @board[*square]) && piece.colour == colour &&
                        (conditions = piece.move?(target))

    conditions_satisfied?(conditions, colour) # Factor in check check
  end

  def move_w_piece(colour, piece: Pawn, file: nil, rank: nil, target: nil, promotee: nil)
    possibles = if file
                  @board.column(file)
                elsif row
                  @board.row(rank)
                else @board
                end

    possibles.select do |piece|
      piece && piece.colour == colour && (conditions = piece.move?(target)) &&
        conditions_satisfied?(conditions, colour) && peice.move(target) # Factor in check check
    end[0]
  end

  ##### TODO
  def conditions_satisfied?(colour, empty: nil, enemy: nil, en_passon: nil, promotion: nil, king_moved: nil, castle: nil)
    in_check?(colour)
  end

  def populate_pawns
    [[1, 'w'], [6, 'b']].each do |(rank, colour)|
      8.times { |file| @board[rank, file] = Pawn.new(colour, file) }
    end
  end

  def populate_back_rank
    [[0, 'w'], [7, 'b']].each do |(rank, colour)|
      [0, 7].each { |file| @board[rank, file] = Rook.new(colour, rank, file) }
      [1, 6].each { |file| @board[rank, file] = Knight.new(colour, rank, file) }
      [2, 5].each { |file| @board[rank, file] = Bishop.new(colour, rank, file) }
      @board[rank, 3] = Queen.new(colour)
      @board[rank, 4] = King.new(colour)
    end
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

Board.new.p
