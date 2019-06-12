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
      draws, date = fewest_draws(results, category)
      assert_operator(draws, :>=, draws(this_result, category), "The version "\
                      "on #{date} had fewer draws when the AI moved #{order}.")
    end
  end

  private

  def losses(hsh)
    hsh['ai_first_results']['ai_losses'] + hsh['ai_second_results']['ai_losses']
  end

  def fewest_draws(results, category)
    date, fewest = results.min_by { |_k, h| draws(h, category) }
    [draws(fewest, category), date]
  end

  def draws(result, category)
    result[category]['draws']
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
    assert_match(/(\S).+\1.+\n.+\1.+\1.+\n.+\1.+\1/, out, "Doesn't p 3x3 grid")
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

  def test_says_cell1_is_first_free
    assert_equal(@board.first_available_cell, 1)
  end
end

class LinesTest < Minitest::Test
  require_relative '../../lib/tic_tac_toe/lines.rb'
  def setup
    @lines = Lines.new([[0, 1, 2]])
  end

  def test_finds_instersects_of_two_lines
    @lines << [0, 3, 6]
    assert_equal([0], @lines.find_intersects)
  end

  def test_finds_intersects_among_three_lines
    @lines.push([0, 3, 6], [2, 4, 6])
    assert_equal([0, 2, 6], @lines.find_intersects)
  end

  def test_returns_empty_if_no_intersects
    @lines << [3, 4, 5]
    assert_empty(@lines.find_intersects)
  end
end

class LineTest < Minitest::Test
  require_relative '../../lib/tic_tac_toe/lines.rb'
  def test_returns_cells_in_row
    assert_equal([0, 1, 2], Line.new(0))
  end

  def test_returns_cells_in_collumn
    assert_equal([0, 3, 6], Line.new(3))
  end
end
