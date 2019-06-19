# Array of words representing a user's guess of the colours in a mastermind code
class Guess < Array
  def initialize(made_earlier = nil)
    str = made_earlier || gets
    @save_instead = /(save|close)/.match?(str)
    super(str.strip.downcase.split)
  end

  class << self
    attr_accessor :colours
  end

  def save_instead?
    @save_instead
  end

  def check_len(desired_length)
    if length == desired_length
      self
    else
      puts "You need to list #{desired_length} colours."
      clear
    end
  end

  def to_code
    return false if empty?

    inject(Code.new) do |code, part|
      code << (match_guess(part) || return)
    end
  end

  private

  def match_guess(part)
    self.class.colours.each_with_index do |colour, i|
      return i if colour[0] == part[0]
    end
    puts "Can't match #{guess} to an available colour."
    false
  end
end
