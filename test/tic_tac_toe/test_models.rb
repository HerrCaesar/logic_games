require 'minitest/autorun'

# Game
class CompletenessTest < Minitest::Test
  require_relative 'completeness_test.rb'
  require 'date'
  def test_no_losses_and_min_draws
    results = TestTicTacToe.new.run_tests
    this_result = results.max_by { |k, _v| get_time(k) }[1]
    assert_equal(losses(this_result), 0, 'The AI loses!')
  end

  private

  def losses(hsh)
    hsh['ai_first_results']['ai_losses'] + hsh['ai_second_results']['ai_losses']
  end

  def lowest_draw_rate(results, category)
    date, fewest = results.min_by { |_k, h| draw_rate(h, category) }
    [draw_rate(fewest, category), date]
  end

  def draw_rate(result, category)
    d = result[category]['draws']
    (100 * d.to_f / (result[category]['ai_wins'] + d)).round(2)
  end

  def get_time(string)
    DateTime.strptime(string, '%d/%m/%Y %H:%M')
  end
end

# Board
class BoardTest < Minitest::Test
  require_relative '../../lib/tic_tac_toe/board.rb'
  def setup
    @board = Board.new
    @board[4] = 'x'
    @board[8] = '○'
  end

  def test_prints_board_to_stdout
    out = capture_io do
      @board.p
    end[0]
    assert_match(/^[^Xx]*[Xx][^Xx]*$/, out, "Didn't print exactly 1 cross")
    assert_match(/^[^o○]*[o○][^o○]*$/, out, "Didn't print exactly 1 naught")
  end

  def test_returns_true_if_cell_free
    assert @board.free?(0)
  end

  def test_returns_false_if_cell_occupied
    refute @board.free?(4)
  end

  def test_shouts_if_cell_occupied
    assert_output(/[:alpha:]+/, '') do
      @board.yell_unless_free?(8)
    end
  end

  def test_quiet_if_cell_free
    assert_silent do
      @board.yell_unless_free?(1)
    end
  end
end

# scores
class ScoresTest < Minitest::Test
  require_relative '../../lib/tic_tac_toe/state_scores.rb'
  def setup
    arr = [
      { score: [0, 1, 1] },
      { score: [2, 1, 0] }
    ]
    @scores = Scores.new(arr)
    @expect = [[0, 0.5, 0.5], [0.66667, 0.33333, 0]]
  end

  def test_normalizes_pointless_scores
    @scores.normalise_scores.each_with_index do |score, i|
      score[:score].each_with_index do |x, j|
        assert_in_delta(@expect[i][j], x)
      end
    end
  end

  def add_points
    hsh = @scores[1]
    hsh[:points] = 2
    @scores[1] = hsh
  end

  def test_normalizes_pointy_scores
    add_points
    @scores.normalise_scores.each_with_index do |score, i|
      score[:score].each_with_index do |x, j|
        assert_in_delta(@expect[i][j], x)
      end
    end
  end

  def test_normalization_preserves_points
    add_points
    expected_points = [nil, 2]
    @scores.normalise_scores.each_with_index do |score, i|
      score[:points] = expected_points[i]
    end
  end

  def test_wisely_avoids_loss
    scores = Scores.new([{ score: [0, 0, 1] }, { score: [0, 1, 0] }])
    assert_equal(1, scores.choose_wisely)
  end

  def test_wisely_avoids_no_win_scenarios
    scores = Scores.new([{ score: [0, 0.5, 0.5] },
                         { score: [0.25, 0.25, 0.5] }])
    assert_equal(1, scores.choose_wisely)
  end

  def test_wisely_prefers_sure_win
    scores = Scores.new([{ score: [1, 0, 0] }, { score: [0.5, 0.5, 0] }])
    assert_equal(0, scores.choose_wisely)
  end

  def test_wisely_prefers_points
    scores = Scores.new([{ points: 2, score: [0.75, 0.25, 0] },
                         { points: 4, score: [0.5, 0.5, 0] }])
    assert_equal(1, scores.choose_wisely)
  end

  def test_wisely_prefers_higher_win_rate
    scores = Scores.new([{ points: 2, score: [0.5, 0.25, 0.25] },
                         { points: 2, score: [0.25, 0.5, 0.25] }])
    assert_equal(0, scores.choose_wisely)
  end
end
