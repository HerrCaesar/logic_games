require_relative '../series_turn_based.rb'
require_relative 'game.rb'
require_relative 'board.rb'

# Tic Tac Toe. Controlled the same as Nim
class TicTacToeSeries < TurnBasedSeries
  def p
    print "Draws - #{draws = @record.count { |out| out == 2 }}; "
    super(@record.length - draws)
  end

  def new_game(id_of_leader, midgame_data = {})
    return new_ai_game(id_of_leader, midgame_data) if @vs_ai

    require_relative 'p_v_p_game.rb'
    @game = PvP.new(midgame_data)
  end

  private

  def new_ai_game(id_of_leader, midgame_data)
    require_relative 'p_v_c_game.rb'
    @game = if @names[id_of_leader] == 'Computer'
              AILead.new(midgame_data)
            else AIFollow.new(midgame_data)
            end
    @game.prepare_root_state(@names[id_of_leader])
  end

  def game_over?(which, changed_cell)
    @game.p
    over = @game.game_over?(@names[which], which, changed_cell)
    @record = @record << over if over
    over
  end
end
