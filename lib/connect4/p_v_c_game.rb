# Computer creates, prints and plays against human on tic-tac-toe board
class PvC < Connect4Game
  include AdditiveStatePvC

  private

  def reload_game_state_from_file
    ai_id = @board.sum(&:count) % 2 # Only save on user's go
    arbitrary_ai_column = @board.index { |c| c.last == ai_id }
    @root_state = C4GameState.new(@board, arbitrary_ai_column, true, ai_id)
    @root_state.evaluate(@board.available)
  end
end

# Game where AI gets to go first
class AILead < PvC
  include AdditiveStateAILead
  def prepare_root_state(_who)
    initial_moves =
      (0..3).each_with_object({}) do |column, hsh|
        new_state = C4AIMovedState.new(@board, column, 0)
        hsh[column] =
          { game_state: new_state, score: new_state.evaluate((0..6).to_a) }
      end
    pick_best_initial(initial_moves)
    p
  end

  def move(who, _which = nil)
    column = @board.sum(&:count).even? ? ai_move(0) : user_move(who, 1)
    return column if column.is_a? Hash

    move_root_state(column)
    column
  end

  private

  def pick_best_initial(moves)
    @board.move(super, 0)
  end
end

# Game where user gets to go first and AI second
class AIFollow < PvC
  def prepare_root_state(who)
    column = user_move(who, 0)
    return column if column.is_a? Hash

    @root_state = C4UserMovedState.new(Board.new, column, 1)
    @root_state.evaluate((0..6).to_a)
  end

  def move(who, _which = nil)
    column = @board.sum(&:count).odd? ? ai_move(1) : user_move(who, 0)
    return column if column.is_a? Hash

    move_root_state(column)
    column
  end
end
