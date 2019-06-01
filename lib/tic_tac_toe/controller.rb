# frozen_string_literal: true

require_relative 'series.rb'
require_relative '../controller_turn_based.rb'

# Controls tic-tac-toe series
class TicTacToe < TurnBased
  def initialize
    setup(TicTacToeSeries)
  end
end

controller = TicTacToe.new
end_series ||= controller.do_a_round until end_series
