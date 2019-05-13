require_relative 'mm_class.rb'
require_relative 'helpers.rb'

def mastermind_settings
  puts 'Enter how many holes and colours you want, or use the default (4, 6).'
  ins = gets.chomp.split
  return default if ins.length != 2

  ins.map!(&:to_i)
  return default if ins.any? { |int| int < 1 }

  if ins[1] > 8
    ins[1] = 8
    puts 'The game only supports 8 colours.'
  end
  Game.new(*ins)
end

def default
  Game.new(4, 6)
end

game = mastermind_settings

puts 'Make a guess by typing colours, or just their first letters'
loop do
  break if game.guess(gets.chomp)

  print 'Guess again:  '
end

puts 'Congratulations!'
