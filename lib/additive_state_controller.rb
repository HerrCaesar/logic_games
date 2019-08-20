%w[additive_state.rb
   additive_state_pvc.rb
   additive_state_game.rb
   series_turn_based.rb
   additive_state_series.rb
   controller_turn_based.rb].each { |f| require_relative(f) }

# Controls series like tic-tac-toe and connect 4
class Additive < TurnBased
  private

  def whose_go
    # vs AI has initialization turn, where mover isn't toggled
    @midgame || (@vs_ai ? @id_of_leader ^ 1 : @id_of_leader)
  end
end
