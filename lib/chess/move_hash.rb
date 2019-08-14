# Describes chess moves using: target, piece, square, rank, file, promotee
class MoveHash < Hash
  PIECES = Hash.new(Pawn).merge!('K' => King, 'Q' => Queen, 'R' => Rook,
                                 'B' => Bishop, 'N' => Knight).freeze
  def add_piece(char)
    self[piece? ? :promotee : :piece] = PIECES[char.upcase]
  end

  def add_target(rank_i, file_i)
    self[:square] = self[:target] if self[:target]
    self[:target] = Vector[rank_i, file_i]
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
end
