# frozen_string_literal: true

# Make an array with some methods that allow it to play nim
class NimGame < Array
  def initialize(size, midgame_data = {})
    if midgame_data.empty?
      size ||= rand(5..10)
      super(size) { rand(1..size) }.sort!
    else
      old_arr = midgame_data['nim']
      super(old_arr.length) { |i| old_arr[i] }
    end
    p
  end

  def move(player_id, who)
    # Wait for appropriate user response then call take
    choice = ask_for_move(player_id, who)
    return choice if choice.is_a? Hash

    return move(player_id, who) if choice.length != 2 ||
                                   choice.any? { |x| x < 1 } ||
                                   choice[0] > self[choice[1] - 1]

    take(choice[0], choice[1] - 1)
  end

  def game_over?(player_id, who)
    return false unless all?(&:zero?)

    puts "\n#{who} wins!"
    player_id
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

  private

  def take(count, row)
    # Remove <count> pips from row <row>
    self[row] -= count
    nil
  end

  def ask_for_move(player_id, who)
    print "\n#{who}, enter how many to take, then which heap (eg '1 3'). "
    puts 'Or save and close the game.'
    return save_game(player_id) if /(save|close)/.match?(choice = gets)

    choice.strip.split.map(&:to_i)
  end

  def save_game(player_id)
    {
      nim: self,
      to_move: player_id
    }
  end
end

# Game between two users
class PvP < NimGame
end

# Game against computer
class PvC < NimGame
  def move(player_id, who)
    who == 'Computer' ? ai_move : super(player_id, who)
  end

  def ai_move
    # Computer chooses move and makes it by calling take
    puts "\nComputer's go:"
    return if try_trivials

    return least_impact if (ns = nimsum).zero?

    val, row = each_with_index.reject { |(x)| (1 << place(ns) & x).zero? }.max
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
