# Control series where on player has a secret which the other guesses
class SecretBased < Controller
  private

  def setup_round
    @series.new_game(@id_of_leader)
    @series.choose_secret(@id_of_leader ^ 1)
  end

  def play_round
    game_over ||= @series.take_turn(@id_of_leader) until game_over
    game_over == 'saved' || stop_playing?
  end

  def midgame?(midgame_data)
    @midgame = !midgame_data.empty?
  end
end
