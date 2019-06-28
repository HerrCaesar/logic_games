require 'colorize'
# Represents Connect 4 board using 7 arrays. 0 = playerA; 1 = playerB
class Board < Array
  HEIGHT = 6
  def initialize(length = nil)
    length ? super : super(7) { [] }
  end

  def move(column, id)
    self[column] << id
  end

  def free?(column)
    self[column].length != HEIGHT
  end

  def yell_unless_free?(column)
    freeness = free?(column)
    puts 'That column is full!' unless freeness
    freeness
  end

  def all?
    (0..5).to_a.none? { |c| free?(c) }
  end

  def game_won?(column)
    id = self[column][-1]
    row = self[column].length - 1
    column_win?(id, column, row) || row_win?(id, column, row) ||
      diag_win?(id, column, row) || diag_win?(id, column, row, true)
  end

  def p
    p_numbers
    p_top
    (1..5).to_a.reverse!.each do |row|
      p_row(row)
      p_mid_divide
    end
    p_row(0)
    p_bottom
  end

  def available
    count { |c| c.length < 6 }
  end

  def dup
    Board.new(each_with_object([]) { |c, a| a << c.dup })
  end

  private

  def column_win?(id, column, row)
    count_adj_sames(id, 1, column, row, y: -1) == true
  end

  def row_win?(id, column, row)
    in_a_row = count_adj_sames(id, 1, column, row, x: -1)
    return true if in_a_row == true

    count_adj_sames(id, in_a_row, column, row, x: 1) == true
  end

  def diag_win?(id, column, row, back = false)
    in_a_row = count_adj_sames(id, 1, column, row, x: -1, y: back ? 1 : -1)
    return true if in_a_row == true

    count_adj_sames(id, in_a_row, column, row, x: 1, y: back ? -1 : 1) == true
  end

  def count_adj_sames(id, in_a_row, column, row, **incrementers)
    c = column
    r = row
    x_crement = incrementers[:x] || 0
    y_crement = incrementers[:y] || 0
    [3, [c, 3, 6 - c][x_crement + 1], [r, 3, 5 - r][y_crement + 1]].min.times do
      return in_a_row unless self[c += x_crement][r += y_crement] == id

      return true if (in_a_row += 1) == 4
    end
    in_a_row
  end

  def p_numbers
    (1..7).to_a.each { |c| print "  #{c}  " }
    puts
  end

  def p_top
    puts '╔════╦════╦════╦════╦════╦════╦════╗'
  end

  def p_row(row)
    7.times do |column|
      print '║ '
      case self[column][row]
      when 0
        print '⬤  '.colorize(:blue)
      when 1
        print '⬤  '.colorize(:red)
      else print '   '
      end
    end
  end

  def p_mid_divide
    puts "║\n╠════╬════╬════╬════╬════╬════╬════╣"
  end

  def p_bottom
    puts "║\n╚════╩════╩════╩════╩════╩════╩════╝"
  end
end
