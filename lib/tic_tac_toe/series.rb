# frozen_string_literal: true

require_relative '../series_turn_based.rb'
require_relative 'games.rb'

# Tic Tac Toe. Controlled the same as Nim
class TicTacToeSeries < TurnBasedSeries
  def p
    print "Draws - #{draws = @record.count { |out| out == 2 }}; "
    super(@record.length - draws)
  end

  private

  def game_over?(which)
    @game.p
    over = @game.game_over?(which, @names[which])
    @record = @record << over if over
    over
  end
end
