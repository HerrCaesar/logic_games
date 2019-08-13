# Store for captured pieces
class Graveyard < Hash
  ORDER = [Queen, Rook, Bishop, Knight, Pawn].freeze

  def initialize
    self['w'] = []
    self['b'] = []
  end

  def p(colour)
    self[colour].each { |piece| print(piece.to_s.center(3)) }
    puts
  end

  def add(piece)
    colour = piece.colour
    index = self[colour].index { |buried| order(buried) <= order(piece) } || 0
    self[colour].insert(index, piece)
  end

  private

  def order(piece)
    ORDER.index(piece.class)
  end
end
