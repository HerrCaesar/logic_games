require_relative 'controller_root.rb'
require_relative 'series_root.rb'

def pick_g
  puts 'What do you want to play:'
  print 'Tic Tac Toe (1), Mastermind (2), Nim (3), or Hangman (4)?  '
  ins = gets.chomp.to_i
  ins.zero? ? pick_g : ins - 1
end

require_relative((%w[tic_tac_toe mastermind nim][pick_g] || 'hangman') +
  '/controller.rb')
