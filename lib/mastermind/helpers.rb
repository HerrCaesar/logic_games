# Underline first letter of string
class Colour < Symbol
  def underline_first
    to_s.capitalize!
    "\e[4m#{self[0]}\e[0m#{self[1..-1]}"
  end
end

# Improve readability when parsing guesses by using method chaining
class GuessArr < Array
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

# Improve readability when parsing guesses by using method chaining
class Guess < String
  def initialize(who)
    puts "#{who}, guess by typing colours, or just their first letters."
    super(gets.strip)
    GuessArr.new(downcase.split)
  end
end
