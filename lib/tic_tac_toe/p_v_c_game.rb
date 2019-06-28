# Computer creates, prints and plays against human on tic-tac-toe board
class PvC < TicTacToeGame
  include OtherID
  include AdditiveStatePvC

  private

  def board_but(cell)
    (0..8).to_a - [cell]
  end

  def reload_game_state_from_file
    ai_symbol = @board.count(&:nil?).even? ? 'x' : '○' # Only save on user's go
    arbitrary_ai_cell = @board.index(ai_symbol)
    @root_state = TTTGameState.new(@board, arbitrary_ai_cell, true, ai_symbol)
    @root_state.evaluate((0..8).to_a.select { |i| @board[i].nil? })
  end
end

# Game where AI gets to go first
class AILead < PvC
  include AdditiveStateAILead
  def prepare_root_state(_who)
    initial_moves =
      [0, 1, 4].each_with_object({}) do |cell, hsh|
        new_state = TTTAIMovedState.new(@board, cell, 'x')
        hsh[cell] =
          { game_state: new_state, score: new_state.evaluate(board_but(cell)) }
      end
    pick_best_initial(initial_moves)
    p
  end

  def move(who, _which = nil)
    cell = @board.count(&:nil?).odd? ? ai_move('x') : user_move(who, '○')
    return cell if cell.is_a? Hash

    move_root_state(cell)
    cell
  end

  private

  def pick_best_initial(moves)
    @board.move(super, 'x')
  end
end

# Game where user gets to go first and AI second
class AIFollow < PvC
  def prepare_root_state(who)
    cell = user_move(who, 'x')
    return cell if cell.is_a? Hash

    @root_state = TTTUserMovedState.new(Board.new, cell, '○')
    @root_state.evaluate(board_but(cell))
  end

  def move(who, _which = nil)
    cell = @board.count(&:nil?).even? ? ai_move('○') : user_move(who, 'x')
    return cell if cell.is_a? Hash

    move_root_state(cell)
    cell
  end
end
