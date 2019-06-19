require_relative 'modules.rb'
require_relative 'game_state.rb'
require_relative 'state_scores.rb'

# Computer creates, prints and plays against human on tic-tac-toe board
class PvC < TicTacToeGame
  include OtherID

  def initialize(midgame_data = {})
    super
    reload_game_state_from_file unless midgame_data.empty?
  end

  private

  def ai_move(id)
    cell = @root_state.children[0][:game_state].cell
    @board[cell] = id
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

  def reload_game_state_from_file
    ai_symbol = @board.count(&:nil?).even? ? 'x' : '○' # Only save on user's go
    arbitrary_ai_cell = @board.index(ai_symbol)
    @root_state = GameState.new(@board, arbitrary_ai_cell, true, ai_symbol)
    @root_state.evaluate((0..8).to_a.select { |i| @board[i].nil? })
  end
end

# Game where AI gets to go first
class AILead < PvC
  def prepare_root_state(_who)
    initial_moves =
      [0, 1, 4].each_with_object({}) do |cell, hsh|
        new_state = GameState.new(@board, cell, true, 'x')
        hsh[cell] =
          { game_state: new_state, score: new_state.evaluate(board_but(cell)) }
      end
    pick_best_initial(initial_moves)
    p
  end

  def move(who, _which = nil)
    cell = @moves_made.even? ? ai_move('x') : user_move(who, '○')
    return cell if cell.is_a? Hash

    move_root_state(cell)
    cell
  end

  private

  def pick_best_initial(moves)
    scores =
      Scores.new(moves.each_with_object([]) { |(_c, h), a| a << h[:score] })
    cell = scores.normalise_scores.choose_wisely**2
    @board[cell] = 'x'
    @moves_made += 1
    @root_state = moves[cell][:game_state]
  end
end

# Game where user gets to go first and AI second
class AIFollow < PvC
  def prepare_root_state(who)
    cell = user_move(who, 'x')
    return cell if cell.is_a? Hash

    @root_state = GameState.new(Board.new, cell, false, '○')
    @root_state.evaluate(board_but(cell))
  end

  def move(who, _which = nil)
    cell = @moves_made.odd? ? ai_move('○') : user_move(who, 'x')
    return cell if cell.is_a? Hash

    move_root_state(cell)
    cell
  end
end
