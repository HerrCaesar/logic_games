%w[controller_root.rb cntrlr_models.rb
   series_root.rb].each { |filename| require_relative(filename) }

def pick_g
  puts 'What do you want to play:'
  print 'Tic Tac Toe (1), Connect 4 (2), Mastermind (3), Nim (4), '\
        'or Hangman (5)?  '
  ins = gets.chomp.to_i
  ins.zero? ? pick_g : ins - 1
end

require_relative((%w[tic_tac_toe connect4 mastermind nim][pick_g] ||
                  'hangman') + '/controller.rb')
