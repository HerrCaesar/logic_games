# frozen_string_literal: true

# Create series of games where they take turns
class TurnBased < Series
  def take_turn(which)
    midgame_data = @game.move(which, @names[which])
    return save_game(midgame_data) if midgame_data

    game_over(which)
  end

  def p(games_count = @record.length)
    p1_ws = @record.count(&:zero?)
    super(p1_ws, games_count - p1_ws)
  end

  def choose_secret(_nil)
    nil
  end
end

# Nim. Controlled the same as Tic Tac Toe
class NimSeries < TurnBased
  require_relative 'nim_games.rb'

  private

  def game_over?(which)
    over = @game.game_over?(@names[which ^ 1])
    over ? @record = @record << (which ^ 1) : @game.p
    over
  end
end

# Tic Tac Toe. Controlled the same as Nim
class TicTacToeSeries < TurnBased
  require_relative 'tic_tac_toe_games.rb'

  def p
    print "Draws - #{draws = @record.count { |out| out == 2 }}; "
    super(@record.length - draws)
  end

  private

  def game_over?(which)
    over = @game.game_over?(which, @names[which])
    over ? @record = @record << over : @game.p
    over
  end
end
