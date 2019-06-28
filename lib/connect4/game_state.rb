# Root of a sub-tree of TTT game states
class C4GameState < GameState
  private

  def childs_frees(parents_frees, column)
    @board[column].length == 5 ? parents_frees - [column] : parents_frees
  end
end

# State as AI moves; has child for each free cell (& corresponding user move)
class C4AIMovedState < C4GameState
  include AIMovedState

  private

  # Create a child game-state for every free cell
  def create_children(free_positions)
    super(free_positions, C4UserMovedState)
  end
end

# State as user moves; will have one child: the best AI move once evaluated
class C4UserMovedState < C4GameState
  include UserMovedState

  private

  def replicate_latest_move
    @board.move(@latest_move, @ai_id ^ 1)
  end

  # Create a child game-state for every free cell
  def create_children(free_positions)
    super(free_positions, C4AIMovedState)
  end
end
