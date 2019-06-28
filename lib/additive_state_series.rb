# Controll series of turn-based games where the possibilities on the next turn
# are always (eventually) fewer than on the current
class AdditiveSeries < TurnBasedSeries
  def p
    print "Draws - #{draws = @record.count { |out| out == 2 }}; "
    super(@record.length - draws)
  end

  private

  def new_ai_game(id_of_leader, midgame_data)
    @game = if @names[id_of_leader] == 'Computer'
              AILead.new(midgame_data)
            else AIFollow.new(midgame_data)
            end
    @game.prepare_root_state(@names[id_of_leader]) if midgame_data.empty?
  end

  def game_over?(which, latest_move)
    @game.p
    over = @game.game_over?(@names[which], which, latest_move)
    @record = @record << over if over
    over
  end
end
