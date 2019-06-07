# frozen_string_literal: true

require_relative '../series_turn_based.rb'
require_relative 'game.rb'
require_relative 'board.rb'
require_relative 'lines.rb'

# Tic Tac Toe. Controlled the same as Nim
class TicTacToeSeries < TurnBasedSeries
  def p
    print "Draws - #{draws = @record.count { |out| out == 2 }}; "
    super(@record.length - draws)
  end

  def new_game(id_of_leader, midgame_data = {})
    @game = if @vs_ai
              require_relative 'p_v_c_game.rb'
              if @names[id_of_leader] == 'Computer'
                AILead.new(midgame_data)
              else AIFollow.new(midgame_data)
              end
            else
              require_relative 'p_v_p_game.rb'
              PvP.new(midgame_data)
            end
  end

  private

  def game_over?(which)
    @game.p
    over = @game.game_over?(which, @names[which])
    @record = @record << over if over
    over
  end
end
