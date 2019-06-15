require_relative '../series_turn_based.rb'
require_relative 'games.rb'

# Nim. Controlled the same as Tic Tac Toe
class NimSeries < TurnBasedSeries
  def new_game(_id_of_leader, midgame_data = {})
    @game = if @vs_ai
              PvC.new(@heaps, midgame_data)
            else PvP.new(@heaps, midgame_data)
            end
  end

  private

  def game_over?(which)
    over = @game.game_over?(which, @names[which ^ 1])
    over ? @record = @record << (which ^ 1) : @game.p
    over
  end
end
