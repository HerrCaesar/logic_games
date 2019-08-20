# A series of chess games. Only PvP
class ChessSeries < TurnBasedSeries
  def new_game(_id_of_leader, midgame_data = {})
    @game = ChessGame.new(midgame_data)
  end

  def p
    print "Draws - #{draws = @record.count { |out| out == 2 }}; "
    super(@record.length - draws)
  end
end
