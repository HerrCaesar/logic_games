# Underline first letter of string
class Symbol
  def underline_first
    to_s.capitalize!
    "\e[4m#{self[0]}\e[0m#{self[1..-1]}"
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

# Handle guesses once converted to array of integers
class Array
  def part_iter
    [dup] + if self[0] > self[1]
              decrement_start
              push1.part_iter + if self[-2] > self[-1]
                                  increment_end.part_iter
                                else []
                                end
            else []
            end
  end

  def compare_cattle(original_code, target)
    code = original_code.dup
    return false unless compare_bulls(code, target[0])

    compare_cows(code, target[1])
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

  def compare_bulls(code, target)
    count = 0
    each_with_index do |colour, slot|
      next unless colour == code[slot]

      count += 1
      return false if count > target

      code[slot] = nil
    end
    count == target
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

  def compare_cows(code, target)
    count = 0
    each_with_index do |colour, slot|
      next unless code[slot]

      next unless (ind = code.index(colour))

      count += 1
      return false if count > target

      code[ind] = -1
    end
    count == target
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

# Improve readability when parsing guesses by using method chaining
class Guess < Array
  def initialize(made_earlier = nil)
    str = made_earlier || gets
    super(str.strip.downcase.split)
  end

  def check_len(desired_length)
    if length == desired_length
      self
    else
      puts "You need to list #{desired_length} colours."
      clear
    end
  end

  def map_2_inds(symbols)
    return false if empty?

    map do |part|
      match = match_guess(part, symbols)
      return false unless match

      match
    end
  end

  private

  def match_guess(part, symbols)
    symbols.each_with_index do |symbol, i|
      return i if symbol[0] == part[0]
    end
    puts "Can't match #{guess} to an available colour."
    false
  end
end
