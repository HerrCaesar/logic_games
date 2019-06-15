# Represents tic-tac-toe board. nil = empty; x = playerA; o = playerB
class Board < Array
  def initialize(length = nil)
    length ? super : super(9)
  end

  def p
    contents = all?(&:nil?) ? method(:cell_num) : method(:space)
    p_top
    each_with_index do |s, i|
      print "║ #{s || contents.call(i)} "
      [2, 5].include?(i) ? p_mid_divide : (p_bottom if i == 9)
    end
    p_bottom
  end

  def game_won?(cell)
    row_done?(cell) || column_done?(cell) || back_diag_done?(cell) ||
      forward_diag_done?(cell)
  end

  def free?(cell)
    self[cell].nil?
  end

  def yell_unless_cell_free?(cell)
    freeness = free?(cell)
    puts 'This square is taken!' unless freeness
    freeness
  end

  private

  def space(_ind)
    ' '
  end

  def cell_num(ind)
    ind + 1
  end

  def p_top
    puts '╔═══╦═══╦═══╗'
  end

  def p_mid_divide
    puts "║\n╠═══╬═══╬═══╣"
  end

  def p_bottom
    puts "║\n╚═══╩═══╩═══╝"
  end

  def row_done?(cell)
    row0 = cell / 3 * 3
    [1, 2].all? { |i| self[row0] == self[row0 + i] }
  end

  def column_done?(cell)
    [3, 6].all? { |i| self[(cell + i) % 9] == self[cell] }
  end

  def back_diag_done?(cell)
    [0, 4, 8].include?(cell) && [4, 8].all? { |i| self[i] == self[0] }
  end

  def forward_diag_done?(cell)
    [2, 4, 6].include?(cell) && [4, 6].all? { |i| self[i] == self[2] }
  end
end
