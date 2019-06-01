# frozen_string_literal: true

require_relative 'games.rb'
require_relative 'helpers.rb'

# Creates series of games between 2 players or between player and computer
class MastermindSeries < Series
  def choose_secret(which_player)
    @game.choose_secret_code(@names[which_player])
  end

  def take_turn(which_player)
    midgame_data = @game.guess(@names[which_player])
    return save_game(midgame_data) if midgame_data.is_a? Hash

    over = @game.game_over?(@names[which_player])
    @record << [which_player, over] if over
    over
  end

  def p
    p1_ws = @record.inject(0) do |wins, (which_player, h_or_s)|
      wins + (%w[hanged stayed].index(h_or_s) ^ which_player)
    end
    super(p1_ws, @record.length - p1_ws)
  end
end
