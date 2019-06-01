# frozen_string_literal: true

# Controls series where the users in the games take turns
class TurnBased < Controller
  private

  def play_round
    whose_go = (@midgame ? @midgame ^ @id_of_leader : @id_of_leader) ^ 1
    game_over ||= @series.take_turn(whose_go ^= 1) until game_over
    game_over == 'saved' || !continue_to_next_game?
  end

  def midgame?(midgame_data)
    @midgame = midgame_data['to_move'] || false
  end
end
