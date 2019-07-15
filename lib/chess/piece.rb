# Record whether a piece has moved. Enables castling and 2-step pawn moves
module Virginity
  def initialize(*args)
    @moved = false
    super(*args)
  end

  def move(new_square)
    super
    @moved = true
  end
end

# Ancestor of all chess piece objects
class Piece
  attr_reader :colour

  def initialize(colour)
    @colour = colour
    @square = Vector[rank, file]
    @taken = false
  end

  def move(new_square)
    @square = new_square
  end

  def to_s
    @symbol
  end

  def taken?
    @taken
  end

  private

  def each_step_to(target, step_vector)
    steps = []
    current = @square + step_vector
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

  def move?(target)
    hsh = case target - @square
          when Vector[1.send(@sign), 0]
            { empty: [target] }
          when Vector[2.send(@sign), 0]
            return @moved ? false : { empty: [target, square_in_front] }
          when Vector[1.send(@sign), 1], Vector[1.send(@sign), -1]
            hsh = { enemy: [target] } ##################################### Dunno
            en_passon_range? ? hsh : (return hsh.merge(en_passon: true))
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
  def move?(target)
    STEPS.include?((target - @square).map!(&:abs))
  end
end

# Moves one space at a time. Can't move into or through check
class King < Melee
  STEPS = [Vector[1, 0], Vector[0, 1], Vector[1, 1]].freeze
  include Virginity

  def initialize(colour)
    super
    @symbol = colour == 'w' ? '♚' : '♔'
  end

  def move?(target)
    return { king_moved: true } if super

    return complain if @moved

    rook, between = case target - @square
                    when Vector[0, 2] # Castle kingside
                      [target + Vector[0, 1], each_step_to(rook, Vector[0, 1])]
                    when Vector[0, -2] # Castle queenside
                      [target - Vector[0, 2], each_step_to(rook, Vector[0, -1])]
                    else (return complain)
                    end
    { unthreatened: between, castle: rook }
  end

  def castle_kingside
    @square[1] += 2
  end

  def castle_queenside
    @square[1] -= 2
  end

  private

  def complain
    if @moved
      puts "Once you've moved the King, he can only move one square at a time."
    else puts "The King can't move like that."
    end
    false
  end
end

# Moves 2 spaces in on direction and one space in the other. Can jump peices
class Knight < Melee
  STEPS = [Vector[2, 1], Vector[1, 2]].freeze
  def initialize(colour, file, promotion = false)
    @symbol = colour == 'w' ? '♞' : '♘'
    super
  end

  def move?(target)
    super ? {} : false
  end
end

# Any piece that can move many spaces in a direction
class Ranged < Piece
  # False if piece can't move there, else return array of all squares in-between
  def move?(target)
    move_vector = (target - @square)
    step_vector = move_vector / move_vector[0].gcd(move_vector[1])
    unless MOVEMENT_VECTORS.include? step_vector.map!(&:abs)
      puts "A #{self.class} can't move like that."
      return false
    end
    { empty: each_step_to(target, step_vector) }
  end
end

# Moves many spaces along a rank, file or diagonal
class Queen < Ranged
  MOVEMENT_VECTORS = [Vector[1, 1], Vector[1, 0], Vector[0, 1]].freeze

  def initialize(colour, file = 3, promotion = false)
    super
    @symbol = colour == 'w' ? '♛' : '♕'
  end
end

# Moves many spaces along a rank or file
class Rook < Ranged
  MOVEMENT_VECTORS = [Vector[1, 0], Vector[0, 1]].freeze
  include Virginity
  attr_reader :moved

  def initialize(colour, file, promotion = false)
    super
    @symbol = colour == 'w' ? '♜' : '♖'
  end

  def castle
    # Move queenside rooks from 0th to 3rd file, and kingside 7th to 5th
    @square[1] = @square[1] / 3 + 3
  end
end

# Moves many spaces along a diagonal
class Bishop < Ranged
  MOVEMENT_VECTORS = [Vector[1, 1]].freeze

  def initialize(colour, file, promotion = false)
    super
    @symbol = colour == 'w' ? '♝' : '♗'
  end
end
