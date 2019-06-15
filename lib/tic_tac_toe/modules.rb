# Maps 1 <-> 4
module OtherID
  SYMBOLS = ['x', '○'].freeze
  def other(id)
    SYMBOLS[SYMBOLS.index(id) ^ 1]
  end
end
