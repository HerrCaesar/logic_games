require 'minitest/autorun'
# Board
class BasicBoardTest < Minitest::Test
  require_relative '../../lib/connect4/board.rb'
  def setup
    @board = Board.new([[0], [], [], [], [], [], []])
  end

  def test_moves_in_incomplete_column
    @board.move(1, 1)
    assert_equal(1, @board[1][0])
  end

  def test_notices_game_not_won
    refute(@board.game_won?(0))
  end

  def test_prints_just_one_token
    out = capture_io { @board.p }[0]
    assert_equal(1, out.scan(/⬤/).length)
  end

  def test_spots_free
    assert(@board.free?(0))
  end

  def test_doesnt_yell_if_free
    assert_empty(capture_io { @board.yell_unless_free?(0) }[0])
  end

  def test_knows_not_all_full
    refute(@board.all?)
  end
end

class PopulatedBoardTest < Minitest::Test
  require_relative '../../lib/connect4/board.rb'
  def setup
    arr = [0, 1, 0, 1, 0, 1]
    @board = Board.new([arr, arr, arr, arr[1..6], arr, arr, arr])
  end

  def test_notices_game_not_won
    refute(@board.game_won?(3))
  end

  def test_prints41_tokens
    out = capture_io { @board.p }[0]
    assert_equal(41, out.scan(/⬤/).length)
  end

  def test_notices_full
    refute(@board.free?(0))
  end

  def test_yells_if_not_free
    refute_empty(capture_io { @board.yell_unless_free?(0) }[0])
  end
end

class DrawnBoardTest < Minitest::Test
  require_relative '../../lib/connect4/board.rb'
  def setup
    arr = [0, 1, 0, 1, 0, 1]
    @board = Board.new([arr, arr, arr, arr.reverse, arr, arr, arr])
  end

  def test_knows_all_full
    assert(@board.all?)
  end

  def test_doesnt_think_game_won
    7.times { |column| refute(@board.game_won?(column)) }
  end
end

class WonBoardTest < Minitest::Test
  require_relative '../../lib/connect4/board.rb'
  def setup
    @arr = [[1, 1, 1, 0], [1, 1, 0], [1, 0], [0], [1], [0], [0]]
  end

  7.times do |column|
    define_method("test_spots_row_win_col#{column}".to_sym) do
      board = Board.new([[1], [1], [0], [0], [0], [0], [1]])
      result = board.game_won?(column)
      column.between?(2, 5) ? assert(result) : refute(result)
    end
  end

  def test_spots_column_win
    board = Board.new([[1], [1], [0, 0, 0, 0], [1], [], [], []])
    assert(board.game_won?(2))
  end

  7.times do |column|
    define_method("test_spots_backslash_diagonal_win_col#{column}".to_sym) do
      result = Board.new(@arr).game_won?(column)
      column < 4 ? assert(result) : refute(result)
    end
  end

  7.times do |column|
    define_method("test_spots_forwardslash_diagonal_win_col#{column}".to_sym) do
      result = Board.new(@arr.reverse).game_won?(column)
      column > 2 ? assert(result) : refute(result)
    end
  end
end
