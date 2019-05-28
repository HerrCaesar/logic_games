# TODO: saves
require './models/nim_and_ttt_series.rb'

# Controls tic-tac-toe series
class TicTacToe < Controller
  def initialize
    setup(TicTacToeSeries)
  end

  private

  def play_round
    whose_go = @leading_player ^= 1
    game_over ||= @series.take_turn(whose_go ^= 1) until game_over
    game_over == 'saved' || !continue_to_next_game?
  end
end

controller = TicTacToe.new
end_series ||= controller.do_a_round until end_series
