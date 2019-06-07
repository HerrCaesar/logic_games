# A group of rows, collumns and/or diagonals, each containing three cells
class Lines < Array
  # Returns array of the indices of empty cells shared by any pair of lines
  def find_intersects
    combination(2).with_object([]) { |(a, b), shared| shared.push(*(a & b)) }
  end
end

# An array of the empty cells that share a row, column or diagonal
class Line < Array
  # Pass the index of a line (0..8); returns array of cells' indices in the line
  def initialize(line_index)
    case line_index
    when 0..2 # Rows
      super(3) { |i| 3 * line_index + i }
    when 3..5 # Columns
      super(3) { |i| line_index + 3 * (i - 1) }
    when 6 # Back-slash diagonal
      super([0, 4, 8])
    else # Forward-slash diagonal
      super([2, 4, 6])
    end
  end
end
