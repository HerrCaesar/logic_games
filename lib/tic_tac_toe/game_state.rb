# Root of a sub-tree of game-states
class GameState
  include OtherID
  attr_reader :score, :children, :cell
  def initialize(board, move_in_cell, ai_go, ai_symbol)
    @cell = move_in_cell
    @board = board.dup
    @board[@cell] = (ai_go ? ai_symbol : other(ai_symbol))
    @ai_go = ai_go
    @ai_symbol = ai_symbol
  end

  def evaluate(free_cells)
    @score =
      case game_over?
      when 2
        [0, 1, 0]
      when 1
        @ai_go ? [1, 0, 0] : [0, 0, 1]
      else evaluate_from_children(free_cells)
      end
  end

  private

  # Reproduces recursively until each descendent has game-over; then scores each
  def evaluate_from_children(free_cells)
    create_children(free_cells)
    @children.each { |h| h[:game_state].evaluate(h[:its_frees]) }
    @ai_go ? average_kids_scores : keep_n_score_best_ai_go_kid
  end

  # Create a child game-state for every free cell
  def create_children(free_cells)
    @children = free_cells.each_with_object([]) do |cell, arr|
      arr << { game_state: GameState.new(@board.dup, cell, !@ai_go, @ai_symbol),
               its_frees: free_cells - [cell] }
    end
  end

  def game_over?
    return 1 if @board.game_won?(@cell)

    @board.all? ? 2 : false
  end

  # kills all children except least valuable to user and returns its value
  def keep_n_score_best_ai_go_kid
    scores = kids_scores
    survivor_index = scores.normalise_scores.choose_wisely
    @children = [@children[survivor_index]]
    scores[survivor_index]
  end

  # Evaluate user's position as equal to average of childrens' values
  def average_kids_scores
    kids_scores.average_scores
  end

  def kids_scores
    Scores.new(@children.map { |child| child[:game_state].score })
  end
end
