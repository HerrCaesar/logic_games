# Root of a sub-tree of game-states, whose every descendent subtree eventually
# terminates in a childless state
class GameState
  attr_reader :score, :children, :latest_move
  def initialize(board, latest_move, ai_id)
    @latest_move = latest_move
    @board = board.dup
    @ai_id = ai_id
    replicate_latest_move
  end

  private

  # Reproduce and evaluate recursively until each descendent has game-over
  def evaluate_from_children(free_positions)
    create_children(free_positions)
    @children.each { |h| h[:game_state].evaluate(h[:its_frees]) }
  end

  # Create a child game-state for every free cell
  def create_children(free_positions, state_class)
    @children = free_positions.each_with_object([]) do |latest_move, arr|
      arr << {
        game_state: state_class.new(@board.dup, latest_move, @ai_id),
        its_frees: childs_frees(free_positions, latest_move)
      }
    end
  end

  def game_over?
    return 1 if @board.game_won?(@latest_move)

    @board.all? ? 2 : false
  end

  def childrens_scores
    Scores.new(@children.map { |child| child[:game_state].score })
  end

  def childs_frees(parents_frees, latest_move)
    parents_frees - [latest_move]
  end
end

# State as AI moves; has child for each free cell (& corresponding user move)
module AIMovedState
  def evaluate(free_positions)
    @score =
      case game_over?
      when 2
        { score: [0, 1, 0] }
      when 1
        { points: 1, score: [1, 0, 0] }
      else evaluate_from_children(free_positions)
      end
  end

  private

  def replicate_latest_move
    @board.move(@latest_move, @ai_id)
  end

  # Average children's scores after recursive reproduction & evaluation
  def evaluate_from_children(free_positions)
    super
    average_kids_scores
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

# State as user moves; will have one child: the best AI move once evaluated
module UserMovedState
  def evaluate(free_positions)
    @score =
      case game_over?
      when 2
        { score: [0, 1, 0] }
      when 1
        { score: [0, 0, 1] }
      else evaluate_from_children(free_positions)
      end
  end

  private

  # Lose all but highest-scoring child after recursive reproduction & evaluation
  def evaluate_from_children(free_positions)
    super
    keep_n_score_best_ai_go_kid
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
