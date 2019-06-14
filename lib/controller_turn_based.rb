# frozen_string_literal: true

# Controls series where the users in the games take turns
class TurnBased < Controller
  private

  def play_round
    mover = whose_go ^ 1
    game_over ||= @series.take_turn(mover ^= 1) until game_over
    game_over == 'saved' || stop_playing?
  end

  def midgame?(midgame_data)
    @midgame = midgame_data['to_move'] || false
  end
end
