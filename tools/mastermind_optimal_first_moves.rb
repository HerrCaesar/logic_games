# Monkey
class Array
  def part_iter
    [dup] + if self[0] > self[1]
              decrement_start
              if self[-2] == self[-1]
                push(1).part_iter
              else
                push1.part_iter + increment_end.part_iter
              end
            else []
            end
  end

  def count_cattle(original_code)
    code = original_code.dup
    [count_bulls(code), count_cows(code)]
  end

  private

  def count_bulls(code)
    count = 0
    each_with_index do |colour, slot|
      next unless colour == code[slot]

      count += 1
      code[slot] = nil
    end
    count
  end

  def count_cows(code)
    count = 0
    each_with_index do |colour, slot|
      next unless code[slot]

      next unless (ind = code.index(colour))

      count += 1
      code[ind] = -1
    end
    count
  end

  def decrement_start
    self[0] -= 1
  end

  def push1
    self + [1]
  end

  def increment_end
    self[0...-1] << self[-1] + 1
  end
end

# Monkey-patch for want of better ideas. In the initial move, the colours and
# their positions are irrelevant; all codes with the same number of colours and
# repitions of those colours are equivalent (e.g. [0, 0, 1] ~ [2, 3, 3]). So
# first partition integers into arrays of integers with that sum. Then translate
# those into the lowest value codes. Then pick the most instructive.
class Integer
  def partition
    array = [self - 1, 1]
    [[self]] + array.part_iter
  end
end

def generate_valid_codes(holes, colours)
  (0...colours).to_a.repeated_permutation(holes).to_a
end

def pick_most_instructive_code(choices_for_first, all_valid)
  options_with_group_sizes = choices_for_first.map do |choice|
    [choice] << all_valid.map { |x| x.count_cattle(choice) }
                         .each_with_object(Hash.new(0)) do |cttl, hsh|
                           hsh[cttl] += 1
                         end.values
  end
  get_best_option(options_with_group_sizes)
end

def get_best_option(options_with_group_sizes)
  options_with_group_sizes.min do |a, b|
    spaceship = n = 0
    while spaceship.zero?
      spaceship = (a[1].max(n + 1)[n] || -1) <=> (b[1].max(n + 1)[n] || 0)
      n += 1
    end
    spaceship
  end[0]
end

def find_optimal_first_move(holes, colours)
  all_valid = generate_valid_codes(holes, colours)
  partitions = holes.partition
  partitions.keep_if { |p| p.length <= colours } if colours < holes
  choices_for_first = partitions.map do |partition|
    partition.each_with_index.each_with_object([]) do |(x, i), a|
      x.times { a << i }
    end
  end
  pick_most_instructive_code(choices_for_first, all_valid)
end

def find_optimal_first_moves_up_to(max_holes, max_colours)
  optimal_first_moves = {}
  (2..max_holes).each do |holes|
    (1...max_colours).each do |colours|
      optimal_move = nil
      time_to_calculate = Benchmark.realtime do
        optimal_move = find_optimal_first_move(holes, colours)
      end
      optimal_first_moves[[holes, colours]] = {
        optimal_first_move: optimal_move,
        time_to_calculate: time_to_calculate
      }
    end
  end
  optimal_first_moves
end

require 'benchmark'
# optimal_first_moves = find_optimal_first_moves_up_to(8, 8).each_value do |v|
#   arr = []
#   v[:optimal_first_move].each { |i| arr[i] = (arr[i] || 0) + 1 }
#   v[:seq_generator] = arr
# end
