# Array of integers representing a possible code during a game of mastermind
class Code < Array
  attr_reader :possible
  class << self
    attr_accessor :colours
  end

  # Return bool representing the possibility of this code being correct
  def compare_cattle(original_code, target)
    code = original_code.dup
    @possible =
      compare_bulls(code, target[0]) && compare_cows(code, target[1])
  end

  def possible?
    @possible
  end

  def count_cattle(original_code)
    code = original_code.dup
    [count_bulls(code), count_cows(code)]
  end

  def print_pips(remaining_guesses)
    print "#{remaining_guesses.to_s.rjust(2)}  "
    each { |i| print "#{'●'.colorize(self.class.colours[i])}  " }
  end

  # Count cattle against multiple codes and return size of all cattle types
  def herd_cattle(possibles)
    possibles.each_with_object(Hash.new(0)) do |poss_code, hsh|
      hsh[count_cattle(poss_code)] += 1
    end.values
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
end
