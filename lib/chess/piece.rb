# Record whether a piece has moved. Enables castling and 2-step pawn moves
module Virginity
  def initialize(*args)
    @moved = false
    super(*args)
  end

  def move(target_square, experiment = nil)
    @moved = if !@moved && experiment == 'out'
               'provisionally'
             else @moved != 'provisionally' || experiment != 'back'
             end
    super(target_square)
  end
end

# Ancestor of all chess piece objects
class Piece
  attr_reader :colour
  attr_reader :square

  def initialize(colour, rank, file)
    @colour = colour
    @square = Vector[rank, file]
    @taken = false
  end

  def move(new_square, _experiment = nil)
    @square = new_square
  end

  def to_s
    @symbol
  end

  def taken?
    @taken
  end

  private

  def grumble(test = false)
    puts "A #{self.class} can't move like that." unless test
    false
  end

  def each_step_to(target, step_vector, inclusive = false)
    steps = []
    current = inclusive ? @square : @square + step_vector
    until current == target
      steps << current
      current += step_vector
    end
    steps
  end
end

# Moves one square forward or 2 if unmoved; captures diagonally; can be promoted
class Pawn < Piece
  include Virginity

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
    promotion_range? ? hsh.merge(promotion: true) : hsh
  end

  private

  def square_in_front
    @square + Vector[1, 0].send(@sign)
  end

  def in_range?(half_ranks)
    @square == (7 + half_ranks.send(@sign)) / 2
  end

  def en_passon_range?
    in_range?(1)
  end

  def promotion_range?
    in_range?(5)
  end
end

# Any piece that can only move to certain spaces near them
class Melee < Piece
  def conds_of_move(target)
    @steps.include?((target - @square).map!(&:abs))
  end
end

# Moves one space at a time. Can't move into or through check
class King < Melee
  include Virginity

  def initialize(colour, rank, file = 4)
    @symbol = colour == 'w' ? '♚' : '♔'
    @steps = [Vector[1, 0], Vector[0, 1], Vector[1, 1]].freeze
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
  def initialize(colour, rank, file)
    @symbol = colour == 'w' ? '♞' : '♘'
    @steps = [Vector[2, 1], Vector[1, 2]].freeze
    super
  end

  def conds_of_move(target, test = false)
    super(target) ? {} : grumble(test)
  end
end

# Any piece that can move many spaces in a direction
class Ranged < Piece
  # False if piece can't move there, else return array of all squares in-between
  def conds_of_move(target, test = false)
    move_vector = (target - @square)
    step_vector = move_vector / move_vector[0].gcd(move_vector[1])
    return grumble(test) unless
      @movement_vectors.include? step_vector.map(&:abs)

    (steps = each_step_to(target, step_vector)).nil? ? {} : { empty: steps }
  end
end

# Moves many spaces along a rank, file or diagonal
class Queen < Ranged
  def initialize(colour, rank, file = 3)
    @symbol = colour == 'w' ? '♛' : '♕'
    @movement_vectors = [Vector[1, 1], Vector[1, 0], Vector[0, 1]].freeze
    super
  end
end

# Moves many spaces along a rank or file
class Rook < Ranged
  include Virginity
  attr_reader :moved

  def initialize(colour, rank, file, promotion = false)
    @symbol = colour == 'w' ? '♜' : '♖'
    @movement_vectors = [Vector[1, 0], Vector[0, 1]].freeze
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
  def initialize(colour, rank, file)
    @symbol = colour == 'w' ? '♝' : '♗'
    @movement_vectors = [Vector[1, 1]].freeze
    super
  end
end
