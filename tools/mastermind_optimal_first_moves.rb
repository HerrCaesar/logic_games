require_relative '../lib/mastermind/helpers.rb'
require 'benchmark'

def generate_valid_codes(holes, colours)
  (0...colours).to_a.repeated_permutation(holes).to_a
end

def pick_most_reductive_code(choices, all_valid, bmk = false)
  choices.map! do |choice|
    [choice] << all_valid.map { |x| x.count_cattle(choice) }
                         .each_with_object(Hash.new(0)) do |cttl, hsh|
                           hsh[cttl] += 1
                         end.values
  end
  bmk ? choices : get_best_option(choices)
end

def pick_most_reductive_code_no_dup(choices, all_valid, bmk = false)
  # Map each choice to an array of its cattle with all_valid.
  # Use while-loop to access previous choices' cattle.
  choices.map!.with_index do |choice, i|
    a_v = all_valid.dup
    [choice] << a_v.map!.with_index do |code, j|
      j < i ? choices[j][1][i] : code.count_cattle(choice)
    end
  end
  # Loop again to do the hashing
  bmk ? group_sizes_of(choices) : get_best_option(group_sizes_of(choices))
end

def group_sizes_of(choices)
  choices.map do |(co, ctls)|
    [co, ctls.each_with_object(Hash.new(0)) { |ctl, hsh| hsh[ctl] += 1 }.values]
  end
end

def get_best_option(options_with_group_sizes)
  options_with_group_sizes.min do |a, b|
    spaceship = n = 0
    while spaceship.zero?
      spaceship = (a[1].max(n + 1)[n] || -1) <=> (b[1].max(n + 1)[n] || 0)
      n += 1
    end
    spaceship
  end
end

def find_optimal_first_move(holes, colours, bmk = false)
  all_valid = generate_valid_codes(holes, colours)
  partitions = holes.partition
  partitions.keep_if { |p| p.length <= colours } if colours < holes
  choices = partitions.map do |partition|
    partition.each_with_index.each_with_object([]) do |(x, i), a|
      x.times { a << i }
    end
  end
  bmk ? [choices, all_valid] : pick_most_reductive_code(choices, all_valid)
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

# optimal_first_moves = find_optimal_first_moves_up_to(8, 8).each_value do |v|
#   arr = []
#   v[:optimal_first_move].each { |i| arr[i] = (arr[i] || 0) + 1 }
#   v[:seq_generator] = arr
# end

def compare_ranchers(holes, colours)
  choices, all_valid = find_optimal_first_move(holes, colours, true)
  first_guess, groups = pick_most_reductive_code(choices, all_valid)
  f_g_cattle = groups.max[0]
  all_valid.keep_if do |code|
    match = code.compare_cattle(first_guess, f_g_cattle)
    choices << code if match
    !match
  end
  all_valid.unshift(*choices)
  pick1 = pick2 = nil
  Benchmark.bmbm do |x|
    x.report('pick_most_reductive_code') do
      pick1 = pick_most_reductive_code(choices.dup, all_valid, true)
    end
    x.report('pick_most_reducti_no_dup') do
      pick2 = pick_most_reductive_code_no_dup(choices.dup, all_valid, true)
    end
  end
  puts pick1 == pick2 ? 'Same result' : 'Different results!!!!!!!!!!!!'
end

def compare_ranchers_for_up_to(max_holes, max_colours)
  (2..max_holes).each do |holes|
    (1..max_colours).each do |colours|
      puts "#{holes} holes, #{colours} colours"
      compare_ranchers(holes, colours)
      puts
    end
  end
end

# compare_ranchers_for_up_to(5, 6)
