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

  def move(who, player_id)
    # Wait for appropriate user response then call take
    choice = ask_for_move(who, player_id)
    return choice if choice.is_a? Hash

    return move(who, player_id) if choice.length != 2 ||
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
      puts "#{(i + 1).to_s.ljust(2)} #{output.center(width)}"
    end
  end

  private

  def take(count, row)
    # Remove <count> pips from row <row>
    self[row] -= count
    true
  end

  def ask_for_move(who, player_id)
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
  def move(who, player_id)
    who == 'Computer' ? ai_move : super(player_id, who)
  end

  def ai_move
    # Computer chooses move and makes it by calling take
    puts "\nComputer's go:"
    return if find_trivials

    return least_impact if (ns = nimsum).zero?

    val, row = each_with_index.find { |(x)| bin_down(ns) & x > 0 }
    take(val - (val ^ ns), row)
  end

  private

  def nimsum
    inject(0) { |xor, x| xor ^ x }
  end

  def find_trivials
    longs = each_with_index.select { |(x)| x > 1 }
    if longs.length == 1
      take(longs[0][0] - (count { |x| x > 0 }.even? ? 0 : 1), longs[0][1])
    else false
    end
  end

  def least_impact
    shift = 0
    loop do
      _val, ind = each_with_index.select { |(x)| 1 << shift & x > 0 }.max
      return take(1, ind) if ind

      shift += 1
    end
  end

  def bin_down(int)
    2**Math.log2(int).floor
  end
end
