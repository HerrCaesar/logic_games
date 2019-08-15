# Describes chess moves using: target, piece, square, rank, file, promotee
class MoveHash < Hash
  PIECES = Hash.new(Pawn).merge!('K' => King, 'Q' => Queen, 'R' => Rook,
                                 'B' => Bishop, 'N' => Knight).freeze
  def add_piece(char)
    self[piece? ? :promotee : :piece] = PIECES[char.upcase]
    self
  end

  def add_target(rank_i, file_i)
    self[:square] = self[:target] if self[:target]
    self[:target] = Vector[rank_i, file_i]
    self
  end

  def target?
    !self[:target].nil?
  end

  def piece?
    !self[:piece].nil?
  end

  def rank?
    !self[:rank].nil?
  end

  def to_move_algebra
    move = check_for_castle || translate_move
    MoveAlgebra.new(conversion: true, value: move)
  end

  private

  def check_for_castle
    return false unless self[:piece] == King && (square = self[:square])

    case (square[1] - self[:target][1]).abs
    when 3
      '0-0-0'
    when 2
      '0-0'
    end
  end

  def translate_move
    # Start with piece. (Always, but '' if pawn)

    # Try rank, else file, else square. (Some; mutually exclusive)

    # Add takes. (Some)

    # Add target. (Always)

    # Add promotion piece. (Some)
  end
end
