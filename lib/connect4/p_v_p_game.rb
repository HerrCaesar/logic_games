# Takes moves from two players, displays them and tests win-conditions
class PvP < Connect4Game
  def move(who, id)
    user_move(who, id)
  end
end
