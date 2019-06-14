require 'minitest/autorun'

# Game
class CompletenessTest < Minitest::Test
  require_relative 'completeness_test.rb'
  require 'date'
  def test_no_losses_and_min_draws
    results = TestTicTacToe.new.run_tests
    this_result = results.max_by { |k, _v| get_time(k) }[1]
    assert_equal(losses(this_result), 0, 'The AI loses!')
    %w[first second].each do |order|
      category = 'ai_' + order + '_results'
      lowest_d_r, date = lowest_draw_rate(results, category)
      this_d_r = draw_rate(this_result, category)
      assert_operator(lowest_d_r, :>=, this_d_r, "Version on #{date} had lower"\
        " draw rate (#{lowest_d_r}% < #{this_d_r}%) when AI moved #{order}.")
    end
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
    @board = Board.new(9) { |i| [0, 3].include?(i) ? i + 1 : 0 }
  end

  def test_prints_board_to_stdout
    out = capture_io do
      @board.p
    end[0]
    assert_match(/^[^Xx]*[Xx][^Xx]*$/, out, "Didn't print exactly 1 cross")
    assert_match(/^[^Oo0]*[Oo0][^Oo0]*$/, out, "Didn't print exactly 1 naught")
  end

  def test_returns_true_if_cell_free
    assert @board.free?(1)
  end

  def test_returns_false_if_cell_occupied
    refute @board.free?(0)
  end

  def test_shouts_if_cell_occupied
    assert_output(/[:alpha:]+/, '') do
      @board.yell_unless_cell_free?(0)
    end
  end

  def test_quiet_if_cell_free
    assert_silent do
      @board.yell_unless_cell_free?(1)
    end
  end
end
