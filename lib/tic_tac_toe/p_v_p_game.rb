# Takes moves from two players, displays them and tests win-conditions
class PvP < TicTacToeGame
  def move(who, which)
    user_move(who, ['x', '○'][which])
  end
end
