# Describes chess moves using Standard Algebraic Notation
# (https://en.wikipedia.org/wiki/Algebraic_notation_(chess))
class MoveAlgebra < String
  def initialize(who: nil, colour: nil, value: nil)
    @colour = colour
    if value
      super(value)
    else
      print "#{who} (#{colour == 'w' ? 'white' : 'black'}), describe your move"\
        ' in algebraic notation. (Or save and close the game)  '
      super(gets.strip)
    end
  end

  # Returns Move representing the same move, or false if this is impossible
  def to_move
    parse_for_castle || parse_for_move
  end

  def file_to_index
    ord - 97
  end

  def rank_to_index
    to_i - 1
  end

  private

  def parse_for_castle
    spaces = case scan(/[0oO]/).length
             when 2
               2
             when 3
               -2
             else (return false)
             end
    king_sq = Vector[@colour == 'w' ? 0 : 7, 4]
    Move.new(colour: @colour, origin: king_sq, piece_type: 'k',
             target: king_sq + Vector[0, spaces == 2 ? 2 : -2])
  end

  def parse_for_move
    move = Move.new(colour: @colour)
    buff = nil
    while (c = slice!(0))
      case c
      when /[KkQqRrBNn]/
        move.add_piece_type(c)
      when /[a-h]/
        move.file = buff if buff
        buff = c.file_to_index
      when /[1-8]/
        if buff
          move.add_target(c.rank_to_index, buff)
          buff = nil
        elsif move.rank
          return false
        else move.rank = c.rank_to_index
        end
      end
    end
    move.target ? move : false
  end
end
