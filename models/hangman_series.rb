# frozen_string_literal: true

require_relative 'hangman_games.rb'

# Creates series of games between 2 players or between player and computer
class HangmanSeries < Series
  def choose_secret(which_player)
    @game.choose_secret_word(@names[which_player])
  end

  def take_turn(which_player)
    @game.print_clue
    @game.print_guesses
    midgame_data = @game.guess(@names[which_player])
    return save_game(midgame_data) if midgame_data

    @game.draw_hanging
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
