# Make an array  with some methods that allow it to play nim
class Nim < Array
  def initialize(size)
    size ||= rand(5..10)
    super(size) { rand(1..size) }.sort!
    p
  end

  def p
    # Print graphical representation of Nim
    dot = "\u25Cf".encode('utf-8')
    width = 2 * max + 1
    each_with_index do |x, i|
      output = ''
      x.times { output += dot + ' ' }
      puts "#{i + 1} #{output.center(width)}"
    end
  end

  def take(count, row)
    # Remove <count> pips from row <row>
    self[row] -= count
  end

  def user_move(player)
    # Wait for appropriate user response then call take
    loop do
      puts "\n#{player}, enter how many to take, then the heap (eg '1 3')."
      ip = gets.strip.split.map!(&:to_i)
      redo if ip.length != 2 || ip.any? { |x| x < 1 } || ip[0] > self[ip[1] - 1]

      return take(ip[0], ip[1] - 1)
    end
  end

  def game_over?(player)
    # Print congratulations or commiseration message
    return false unless all?(&:zero?)

    puts "\n#{player} wins!"
    true
  end
end

# Game between two users
class PvP < Nim
end

# Game against computer
class PvC < Nim
  def ai_move
    # Computer chooses move and makes it by calling take
    puts "\nComputer's go:"
    return if try_trivials

    ns = nimsum
    return least_impact if ns.zero?

    order_ns = 1 << place(ns)
    val, row = each_with_index.reject { |(x)| (order_ns & x).zero? }.max
    take(val - (val ^ ns), row)
  end

  private

  def nimsum
    inject(0) { |xor, x| xor ^ x }
  end

  def try_trivials
    choice = nil
    ones = 0
    each_with_index do |x, i|
      if x > 1
        return false if choice

        choice = [x, i]
      else
        ones = ones ^ 1
      end
    end
    choice ? take(choice[0] - ones, choice[1]) : take(1, index(1))
    true
  end

  def least_impact
    shift = 0
    loop do
      _val, ind = each_with_index.select { |(x)| 1 << shift & x }.max
      return take(1, ind) if ind

      shift += 1
    end
  end

  def place(int)
    i = -1
    until int.zero?
      i += 1
      int = int >> 1
    end
    i
  end
end
