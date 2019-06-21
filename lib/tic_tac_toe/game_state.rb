# Root of a sub-tree of game-states
class GameState
  include OtherID
  attr_reader :score, :children, :cell
  def initialize(board, move_in_cell, ai_symbol)
    @cell = move_in_cell
    @board = board.dup
    @ai_symbol = ai_symbol
  end

  private

  # Reproduce and evaluate recursively until each descendent has game-over
  def evaluate_from_children(free_cells)
    create_children(free_cells)
    @children.each { |h| h[:game_state].evaluate(h[:its_frees]) }
  end

  def game_over?
    return 1 if @board.game_won?(@cell)

    @board.all? ? 2 : false
  end

  def childrens_scores
    Scores.new(@children.map { |child| child[:game_state].score })
  end
end

# State as AI moves; has child for each free cell (& corresponding user move)
class AIMovedState < GameState
  def initialize(board, move_in_cell, ai_symbol)
    super
    @board[@cell] = ai_symbol
  end

  def evaluate(free_cells)
    @score =
      case game_over?
      when 2
        { score: [0, 1, 0] }
      when 1
        { points: 1, score: [1, 0, 0] }
      else evaluate_from_children(free_cells)
      end
  end

  private

  # Average children's scores after recursive reproduction & evaluation
  def evaluate_from_children(free_cells)
    super
    average_kids_scores
  end

  # Create a child game-state for every free cell
  def create_children(free_cells)
    @children = free_cells.each_with_object([]) do |cell, arr|
      arr << {
        game_state: UserMovedState.new(@board.dup, cell, @ai_symbol),
        its_frees: free_cells - [cell]
      }
    end
  end

  # Evaluate user's position as equal to average of childrens' values
  def average_kids_scores
    kids_scores = childrens_scores
    score = kids_scores.average_scores
    points = kids_scores.max_points
    points += 1 if score == [1, 0, 0]
    { points: points, score: score }
  end
end

# State as user moves; will have one child - the best AI move once evaluated
class UserMovedState < GameState
  def initialize(board, move_in_cell, ai_symbol)
    super
    @board[@cell] = other(ai_symbol)
  end

  def evaluate(free_cells)
    @score =
      case game_over?
      when 2
        { score: [0, 1, 0] }
      when 1
        { score: [0, 0, 1] }
      else evaluate_from_children(free_cells)
      end
  end

  private

  # Lose all but highest-scoring child after recursive reproduction & evaluation
  def evaluate_from_children(free_cells)
    super
    keep_n_score_best_ai_go_kid
  end

  # Create a child game-state for every free cell
  def create_children(free_cells)
    @children = free_cells.each_with_object([]) do |cell, arr|
      arr << {
        game_state: AIMovedState.new(@board.dup, cell, @ai_symbol),
        its_frees: free_cells - [cell]
      }
    end
  end

  # kills all children except least valuable to user and returns its value
  def keep_n_score_best_ai_go_kid
    scores = childrens_scores
    return scores[0] if scores.length == 1

    survivor_index = scores.normalise_scores.choose_wisely
    @children = [@children[survivor_index]]
    scores[survivor_index]
  end
end
