# Help manage identification of pieces and players using black/white
module Colours
  def word_from(colour)
    colour == 'w' ? 'white' : 'black'
  end
end

# Record whether a piece has moved. Enables castling and 2-step pawn moves
module Virginity
  def initialize(*args)
    @moved = false
    super(*args)
  end

  def move(target_square, back = false)
    @moved = if !@moved
               'provisionally'
             else @moved != 'provisionally' || !back
             end
    super(target_square)
  end
end

# Movement vectors for each closest square a rook could move to
module RookSteps
  def rook_steps
    (pos = [Vector[0, 1], Vector[1, 0]]) + pos.map(&:-@)
  end
end

# Movement vectors for each closest square a bishop could move to
module BishopSteps
  def bishop_steps
    (pos = [Vector[1, 1], Vector[1, -1]]) + pos.map(&:-@)
  end
end

# Ranged pieces and kings can move multiple spaces; they need to know the path
module MultipleSteps
  def each_step_to(target, step, inclusive = false)
    steps = []
    current = inclusive ? @square : @square + step
    until current == target
      steps << current
      current += step
    end
    steps
  end
end
