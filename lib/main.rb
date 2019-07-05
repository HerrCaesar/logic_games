%w[controller_root.rb cntrlr_models.rb
   series_root.rb].each { |filename| require_relative(filename) }

def pick_g
  puts 'What do you want to play:'
  print 'Mastermind (1), Nim (2), Tic Tac Toe (3), Connect 4 (4), '\
        'or Hangman (5)?  '
  ins = gets.chomp.to_i
  ins.zero? ? pick_g : ins - 1
end

require_relative((%w[mastermind nim tic_tac_toe connect4][pick_g] ||
                  'hangman') + '/controller.rb')
