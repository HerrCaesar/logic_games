# Controls series like tic-tac-toe and connect 4
class Additive < TurnBased
  private

  def whose_go
    # vs AI has initialization turn, where mover isn't toggled
    @midgame || (@vs_ai ? @id_of_leader ^ 1 : @id_of_leader)
  end
end
