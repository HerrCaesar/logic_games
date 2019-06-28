# Tic Tac Toe. Controlled the same as Nim
class Connect4Series < AdditiveSeries
  def new_game(id_of_leader, midgame_data = {})
    return new_ai_game(id_of_leader, midgame_data) if @vs_ai

    require_relative 'p_v_p_game.rb'
    @game = PvP.new(midgame_data)
  end

  private

  def new_ai_game(id_of_leader, midgame_data)
    %w[../additive_state_pvc.rb p_v_c_game.rb ../additive_state.rb game_state.rb
       ../additive_state_score.rb].each { |f| require_relative(f) }
    super
  end
end
