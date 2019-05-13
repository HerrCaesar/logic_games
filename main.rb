def which_game
  puts 'What do you want to play: Tic Tac Toe (1), Mastermind (2), or Nim (3)?'
  ins = gets.chomp.to_i
  case ins
  when 2
    require_relative 'mastermind.rb'
  when 3
    require_relative 'nim.rb'
  else
    require_relative 'tic_tac_toe.rb'
  end
end

which_game
