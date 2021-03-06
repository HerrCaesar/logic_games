# Ancestor of all chess piece objects
class Piece
  attr_reader :colour
  attr_reader :square

  class << self
    attr_reader :steps
  end

  def initialize(colour, rank, file)
    @colour = colour
    @square = Vector[rank, file]
  end

  def move(new_square, _experiment = nil)
    @square = new_square
  end

  def to_s
    @symbol
  end

  def possible_targets
    steps.map { |v| @square + v }
         .keep_if { |v| v.all? { |x| x.between?(0, 7) } }
  end

  private

  def steps
    self.class.steps
  end

  def grumble(test = false)
    puts "A #{self.class} can't move like that." unless test
    false
  end
end

# Moves one square forward or 2 if unmoved; captures diagonally; can be promoted
class Pawn < Piece
  include Virginity
  @steps = [Vector[1, 0], Vector[1, 1], Vector[1, -1]]

  def initialize(colour, rank, file)
    super
    @symbol, @sign = colour == 'w' ? ['♟', :+@] : ['♙', :-@]
  end

  def conds_of_move(target, test = false)
    hsh =
      case target - @square
      when Vector[1.send(@sign), 0]
        { empty: [target] }
      when Vector[2.send(@sign), 0]
        return @moved ? false : { empty: [target, square_in_front] }
      when Vector[1.send(@sign), 1], Vector[1.send(@sign), -1]
        return { enemy: [target, target - Vector[1.send(@sign), 0]] } if
          en_passon_range?

        { enemy: [target] }
      else (return grumble(test))
      end
    promotion_range? ? hsh.merge(promotion: target) : hsh
  end

  private

  def square_in_front
    @square + Vector[1, 0].send(@sign)
  end

  def en_passon_range?
    in_range?(1)
  end

  def promotion_range?
    in_range?(5)
  end

  def in_range?(half_ranks)
    @square[0] == (7 + half_ranks.send(@sign)) / 2
  end
end

# Any piece that can only move to certain spaces near them
class Melee < Piece
  def conds_of_move(target)
    steps.include?(target - @square)
  end
end

# Moves one space at a time. Can't move into or through check
class King < Melee
  include Virginity
  include MultipleSteps
  extend RookSteps
  extend BishopSteps
  @steps = (rook_steps + bishop_steps).freeze

  def initialize(colour, rank, file = 4)
    @symbol = colour == 'w' ? '♚' : '♔'
    super
  end

  def conds_of_move(target, test = false)
    return {} if super(target)

    return complain(test) if @moved

    rook_square, king_step =
      case target - @square
      when Vector[0, 2] # Castle kingside
        [@square + Vector[0, 3], Vector[0, 1]]
      when Vector[0, -2] # Castle queenside
        [@square + Vector[0, -4], Vector[0, -1]]
      else (return complain(test))
      end

    {
      empty: each_step_to(rook_square, king_step),
      unthreatened: each_step_to(target, king_step, true),
      move_rook: { from: rook_square, to: @square + king_step }
    }
  end

  def castle_kingside
    @square[1] += 2
  end

  def castle_queenside
    @square[1] -= 2
  end

  private

  def complain(test)
    if test
    elsif @moved
      puts "Once you've moved the King, he can only move one square at a time."
    else puts "The King can't move like that."
    end
    false
  end
end

# Moves 2 spaces in on direction and one space in the other. Can jump peices
class Knight < Melee
  @steps = ((b = (a = [Vector[2, 1], Vector[1, 2]]) +
                  a.map { |v| Matrix[[-1, 0], [0, 1]] * v }) +
             b.map(&:-@)).freeze

  def initialize(colour, rank, file)
    @symbol = colour == 'w' ? '♞' : '♘'
    super
  end

  def conds_of_move(target, test = false)
    super(target) ? {} : grumble(test)
  end
end

# Any piece that can move many spaces in a direction
class Ranged < Piece
  include MultipleSteps
  # False if piece can't move there, else return array of all squares in-between
  def conds_of_move(target, test = false)
    move_vector = (target - @square)
    step_vector = move_vector / move_vector[0].gcd(move_vector[1])
    return grumble(test) unless steps.include? step_vector

    (path = each_step_to(target, step_vector)).nil? ? {} : { empty: path }
  end
end

# Moves many spaces along a rank, file or diagonal
class Queen < Ranged
  extend RookSteps
  extend BishopSteps
  @steps = (rook_steps + bishop_steps).freeze

  def initialize(colour, rank, file = 3)
    @symbol = colour == 'w' ? '♛' : '♕'
    super
  end
end

# Moves many spaces along a rank or file
class Rook < Ranged
  include Virginity
  extend RookSteps
  @steps = rook_steps.freeze
  attr_reader :moved

  def initialize(colour, rank, file, promotion = false)
    @symbol = colour == 'w' ? '♜' : '♖'
    super(colour, rank, file)
    @moved = promotion
  end

  def castle
    # Move queenside rooks from 0th to 3rd file, and kingside 7th to 5th
    @square[1] = @square[1] / 3 + 3
  end
end

# Moves many spaces along a diagonal
class Bishop < Ranged
  extend BishopSteps
  @steps = bishop_steps.freeze

  def initialize(colour, rank, file)
    @symbol = colour == 'w' ? '♝' : '♗'
    super
  end
end
