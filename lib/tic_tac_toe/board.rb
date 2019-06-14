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

  def free?(cell)
    self[cell].zero?
  end

  def yell_unless_cell_free?(cell)
    freeness = free?(cell)
    puts 'This square is taken!' unless freeness
    freeness
  end

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
