# Takes moves from two players, displays them and tests win-conditions
class PvP < TicTacToeGame
  def move(which, who)
    user_move([1, 4][which], who)
  end
end
