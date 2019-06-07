# Represents tic-tac-toe board. 0 = empty; 1 = playerA; 4 = playerB
class Board < Array
  def p
    each_with_index do |x, i|
      print [' ', 'x', 'o'][Integer.sqrt(x)] + (i % 3 == 2 ? "\n" : '|')
    end
  end

  def free?(cell)
    self[cell].zero?
  end

  def yell_unless_cell_free?(cell)
    freeness = free?(cell)
    puts 'This square is taken!' unless freeness
    freeness
  end

  def first_available_cell
    each_with_index { |x, i| return i if x.zero? }
  end
end
