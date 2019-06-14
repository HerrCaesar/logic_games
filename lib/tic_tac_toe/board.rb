# Represents tic-tac-toe board. 0 = empty; 1 = playerA; 4 = playerB
class Board < Array
  def initialize(length = nil, &block)
    length ? super : super(9) { 0 }
  end

  def p
    blank = all?(&:zero?) ? method(:cell_num) : method(:spaces)
    p_top
    each_with_index do |f, i|
      print '║' + [blank.call(i), ' x ', ' o '][Integer.sqrt(f)]
      [2, 5].include?(i) ? p_mid_divide : (p_bottom if i == 9)
    end
    p_bottom
  end

  def game_won?(cell)
    row0 = cell / 3 * 3
    [1, 2].all? { |i| self[row0] == self[row0 + i] } ||
      [3, 6].all? { |i| self[(cell + i) % 9] == self[cell] } ||
      [0, 4, 8].include?(cell) && [4, 8].all? { |i| self[i] == self[0] } ||
      [2, 4, 6].include?(cell) && [4, 6].all? { |i| self[i] == self[2] }
  end

  def free?(cell)
    self[cell].zero?
  end

  def yell_unless_cell_free?(cell)
    freeness = free?(cell)
    puts 'This square is taken!' unless freeness
    freeness
  end

  private

  def spaces(_ind)
    '   '
  end

  def cell_num(ind)
    " #{ind + 1} "
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
end
