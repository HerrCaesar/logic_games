require 'minitest/autorun'
require_relative '../../lib/mastermind/code.rb'

class TestCode < Minitest::Test
  def setup
    @code = Code.new([0, 1, 2, 2])
  end

  TEST_DATA = {
    cd: [[3, 3, 4, 5], [3, 3, 4, 2], [3, 3, 4, 0],
         [3, 2, 4, 2], [0, 1, 2, 2]].map! { |code| Code.new(code) },
    cattle: [[0, 0], [1, 0], [0, 1], [1, 1], [4, 0]],
    words: %w[to_none bulls cows bulls_and_cows identical]
  }.freeze

  (0..4).to_a.each do |i|
    define_method("test_counts_#{TEST_DATA[:words][i]}".to_sym) do
      assert_equal(TEST_DATA[:cattle][i], @code.count_cattle(TEST_DATA[:cd][i]))
    end

    define_method("test_counts_#{TEST_DATA[:words][i]}".to_sym) do
      assert(@code.compare_cattle(TEST_DATA[:cd][i], TEST_DATA[:cattle][i]))
    end

    ((0..4).to_a - [i]).each do |j|
      define_method("test_cattle_comparison_#{i}_#{j}".to_sym) do
        refute(@code.compare_cattle(TEST_DATA[:cd][i], TEST_DATA[:cattle][j]))
      end
    end
  end
end

class Array
  def to_code
    map! { |code| Code.new(code) }
  end
end

class CodeData < Minitest::Test
  CODES = [[0, 0], [0, 1], [0, 2], [1, 0], [1, 1]].to_code.freeze
  GROUPS = [[3], [3], [2], [2], [2, 2], [3], [2], [2, 2], [4]].map! do |arr|
    (5 - arr.sum).times { arr << 1 }
    arr
  end.freeze
end

class TestCodeHerding < CodeData
  [0, 1, 2].repeated_permutation(2).with_index do |code, i|
    define_method("test_herds_#{code.join('_')}".to_sym) do
      assert_equal(GROUPS[i], Code.new(code).herd_cattle(CODES).sort!.reverse!)
    end
  end
end

class TestCodes < CodeData
  require_relative '../../lib/mastermind/codes.rb'
  def setup
    @poss_codes = Codes.new CODES
    @all_codes = Codes.new([0, 1, 2].repeated_permutation(2).to_a.to_code)
  end

  def test_picks_most_instructive_from_subset
    assert_includes([[0, 2], [1, 0], [2, 0]],
                    @all_codes.most_instructive(@poss_codes))
  end

  def test_picks_most_instructive_from_superset
    assert_equal([0, 1], @poss_codes[0..1].most_instructive(@all_codes))
  end

  def test_gives_prescedence_to_possible_codes
    @all_codes[0..4] = @all_codes[0..4].each do |code|
      code.instance_variable_set(:@possible, true)
    end
    assert_includes([[0, 2], [1, 0]], @all_codes.most_instructive(@poss_codes))
  end

  def first_pass
    @all_codes.full.sort_by_cattle!(Code.new([1, 2]), [1, 0])
  end

  def test_sorts_virgin_codes_by_cattle
    first_pass
    assert_empty([[0, 2], [1, 0], [1, 1], [2, 2]] - @all_codes[0..3])
  end

  def test_sort_sets_possibles_in_virgin_codes
    first_pass
    assert(@all_codes[0..3].all?(&:possible?))
  end

  def test_sort_sets_impossibles_in_virgin_codes
    first_pass
    refute(@all_codes[4..-1].any?(&:possible?))
  end

  def test_sort_resets_first_imposs_in_virgin_codes
    first_pass
    assert_equal(4, @all_codes.first_imposs)
  end

  def second_pass
    @all_codes.sort_by_cattle!(Code.new([2, 1]), [1, 0])
  end

  def test_sorts_used_codes_by_cattle
    first_pass
    second_pass
    assert_empty([[1, 1], [2, 2]] - @all_codes[0..1])
  end

  def test_sort_sets_possibles_in_used_codes
    first_pass
    second_pass
    assert(@all_codes[0..1].all?(&:possible?))
  end

  def test_sort_sets_impossibles_in_used_codes
    first_pass
    second_pass
    refute(@all_codes[2..-1].any?(&:possible?))
  end

  def test_sort_resets_first_imposs_in_used_codes
    first_pass
    second_pass
    assert_equal(2, @all_codes.first_imposs)
  end
end
