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
    [[self]] + [self - 1, 1].part_iter
  end
end

# Partition implementation
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

  private

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
