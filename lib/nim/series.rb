# Nim. Controlled the same as Tic Tac Toe
class NimSeries < TurnBasedSeries
  def new_game(_id_of_leader, midgame_data = {})
    @game = if @vs_ai
              PvC.new(@heaps, midgame_data)
            else PvP.new(@heaps, midgame_data)
            end
  end
end
