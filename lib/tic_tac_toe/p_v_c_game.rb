require_relative 'modules.rb'
require_relative 'game_state.rb'
require_relative 'state_scores.rb'

# Computer creates, prints and plays against human on tic-tac-toe board
class PvC < TicTacToeGame
  include OtherID

  private

  def ai_move(id)
    cell = @root_state.children[0][:game_state].cell
    draw(cell, id)
    @moves_made += 1
    cell
  end

  def move_root_state(cell)
    index = @root_state.children.index do |child|
      child[:game_state].cell == cell
    end
    @root_state = @root_state.children[index][:game_state]
  end

  def board_but(cell)
    (0..8).to_a - [cell]
  end
end

# Game where AI gets to go first
class AILead < PvC
  def prepare_root_state(_who)
    initial_moves =
      [0, 1, 4].each_with_object({}) do |cell, hsh|
        new_state = GameState.new(@board, cell, true, 1)
        hsh[cell] =
          { game_state: new_state, score: new_state.evaluate(board_but(cell)) }
      end
    pick_best_initial(initial_moves)
    p
  end

  def move(who, _which = nil)
    cell = @moves_made.even? ? ai_move(1) : user_move(who, 4)
    return cell if cell.is_a? Hash

    move_root_state(cell)
  end

  private

  def pick_best_initial(moves)
    scores =
      Scores.new(moves.each_with_object([]) { |(_c, h), a| a << h[:score] })
    cell = scores.normalise_scores.choose_wisely**2
    draw(cell, 1)
    @moves_made += 1
    @root_state = moves[cell][:game_state]
  end
end

# Game where user gets to go first and AI second
class AIFollow < PvC
  def prepare_root_state(who)
    cell = user_move(who, 1)
    return cell if cell.is_a? Hash

    @root_state = GameState.new(Board.new, cell, false, 4)
    @root_state.evaluate(board_but(cell))
  end

  def move(who, _which = nil)
    cell = @moves_made.odd? ? ai_move(4) : user_move(who, 1)
    return cell if cell.is_a? Hash

    move_root_state(cell)
  end
end
