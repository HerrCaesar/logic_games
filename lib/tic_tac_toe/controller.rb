%w[../additive_state_controller.rb
   modules.rb
   board.rb
   game_state.rb
   game.rb
   series.rb].each { |f| require_relative(f) }

# Controls tic-tac-toe series
class TicTacToe < Additive
  def initialize
    setup(TicTacToeSeries)
  end
end

if /main\.rb$/.match? $PROGRAM_NAME
  controller = TicTacToe.new
  end_series ||= controller.do_a_round until end_series
end
