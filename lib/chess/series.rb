# A series of chess games. Only PvP
class ChessSeries < TurnBasedSeries
  def new_game(_id_of_leader, midgame_data = {})
    @game = ChessGame.new(midgame_data)
  end

  private

  def game_over?(which, _latest_move)
    over = @game.game_over?(which, @names[which ^ 1])
    over ? @record = @record << (which ^ 1) : @game.p
    over
  end
end
