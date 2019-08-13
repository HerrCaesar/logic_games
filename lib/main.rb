%w[controller_root.rb cntrlr_models.rb
   series_root.rb].each { |filename| require_relative(filename) }

def pick_g
  puts 'What do you want to play:'
  print 'Mastermind (1), Nim (2), Tic Tac Toe (3), Connect 4 (4), Hangman (5)'\
        ' or Chess (6)?  '
  ins = gets.chomp.to_i
  ins.between?(1, 6) ? ins - 1 : pick_g
end

require_relative((%w[mastermind nim tic_tac_toe connect4 hangman][pick_g] ||
                  'chess') + '/controller.rb')
