# Control series where the players in the games take turns
class TurnBased < Controller
  private

  def setup_round
    @series.new_game(@id_of_leader)
  end

  def play_round
    mover = whose_go ^ 1
    game_over ||= @series.take_turn(mover ^= 1) until game_over
    game_over == 'saved' || stop_playing?
  end

  def midgame?(midgame_data)
    @midgame = midgame_data['to_move'] || false
  end
end
