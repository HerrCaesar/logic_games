require_relative 'nm_class.rb'

# Create series of games against ai or between 2 players
class NimSeries
  attr_accessor :record

  def initialize(heaps, vs_ai, names)
    @heaps = heaps
    @vs_ai = vs_ai
    @names = names
    @record = []
  end

  def new_game
    @game = @vs_ai ? PvC.new(@heaps) : PvP.new(@heaps)
  end

  def move(who)
    @names[who] == 'Computer' ? @game.ai_move : @game.user_move(@names[who])
    over = @game.game_over?(@names[who ^ 1])
    over ? @record = @record << (who ^ 1) : @game.p
    over
  end

  def p
    @names.each_with_index do |name, i|
      print "#{name} - #{@record.count { |x| x == i }}; "
    end
    puts "\b\b"
  end
end

puts "What's your name?"
name = gets.strip || 'Player 1'
names = [name.capitalize]

puts "How many heaps? (Or type 'r' for random.)"
heaps = gets.chomp.to_i
heaps = heaps < 1 ? nil : [heaps, 50].min

puts '1-player (1) or 2-player (2)?'
vs_ai = gets.strip.to_i != 2

if vs_ai
  names << 'Computer'
  puts 'Do you want to go first in game 1?'
  names.reverse! unless gets =~ /[yY]/
else
  puts "What's player 2's name?"
  names << (gets.strip || 'Player 2')
end

series = NimSeries.new(heaps, vs_ai, names)
continue = true
starting_player = 0
while continue
  series.new_game
  game_over = false
  player = starting_player
  until game_over
    game_over = series.move(player)
    player ^= 1
  end
  series.p
  puts 'Rematch?'
  break unless gets =~ /[yY]/

  starting_player ^= 1
end
