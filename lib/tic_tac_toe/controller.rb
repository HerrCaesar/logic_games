require_relative 'series.rb'
require_relative '../controller_turn_based.rb'

# Controls tic-tac-toe series
class TicTacToe < TurnBased
  def initialize
    setup(TicTacToeSeries)
  end

  private

  def whose_go
    # TTT vs AI has initialization turn, where mover isn't toggled
    @midgame || (@vs_ai ? @id_of_leader ^ 1 : @id_of_leader)
  end
end

if /main\.rb$/.match? $PROGRAM_NAME
  controller = TicTacToe.new
  end_series ||= controller.do_a_round until end_series
end
