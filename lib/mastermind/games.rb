# frozen_string_literal: true

require 'colorize'
require 'io/console'

# Sets up the game and responds to guesses
class MastermindGame
  COLOURS = %i[red blue green yellow cyan white light_magenta black].freeze
  def initialize(slots = 2, colours_i = 3, midgame_data = {})
    @colours_i = colours_i
    @max_guesses = ((slots * colours_i)**0.7).round
    @guesses = midgame_data['guesses'] || []
  end

  private

  def list_colours
    (0...@colours_i).each do |i|
      colour = COLOURS[i]
      print "#{colour.underline_first.colorize(colour)} "
    end
    puts
  end

  def display_guess(the_guess)
    dot = "\u25Cf".encode('utf-8')
    print "\r\e[1A\r#{@guesses.length.to_s.rjust(3, ' ')}  "
    the_guess.each { |i| print "#{dot.colorize(COLOURS[i])}  " }
  end

  def count_cattle
    code = @code.dup
    bulls = get_bulls(the_guess, code)
    bulls.each { |i| [code, the_guess].each { |arr| arr.delete_at(i) } }
    [bulls.length, count_cows(the_guess, code)]
  end.reverse

  def get_bulls(the_guess, code)
    code.each_with_index.inject([]) do |bullish, (colour, slot)|
      colour == the_guess[slot] ? bullish << slot : bullish
    end
  end

  def count_cows(the_guess, code)
    code.inject(0) do |count, colour|
      where = the_guess.index(colour)
      the_guess.delete_at(where) if where
      count + (where ? 1 : 0)
    end
  end

  def display_feedback(bulls, cows)
    puts "  #{bulls} bull#{s?(bulls)}, #{cows} cow#{s?(cows)}"
    [bulls, cows]
  end

  def s?(str)
    str == 1 ? '' : 's'
  end
end

# User chooses secret code and AI guesses it
class AILead < MastermindGame
  def initialize(slots = 2, colours_i = 3, midgame_data = {})
    super
    @all_valid = generate_valid_codes(slots, colours_i)
    @poss = midgame_data['poss'] || @all_valid
  end

  def choose_secret_code(who)
    list_colours
    puts "#{who}, pick a secret code and remember it. Press enter when ready."
    gets
  end

  def guess(_who)
    the_guess = @poss.sample
    @guesses << the_guess
    display_guess(the_guess)
    feedback
  end

  private

  def generate_valid_codes(slots, colours_i)
    (0...colours_i).to_arr.repeated_combination(slots).to_a.map do |arr|
      arr.permutation(slots).to_a.uniq
    end.flatten(1)
  end

  def feedback(verbose = false)
    cattle = get_feedback(verbose)
    return cattle if cattle.is_a? Hash # ie contains save-data

    @poss.keep_if do |code|
      code.count_cattle == cattle
    end
  end

  def get_feedback(verbose = false)
    ask_for_feedback(verbose)
    case gets_without_return
    when /[hH]/
      get_feedback(true)
    when /[sScC]/
      save_game
    else parse_feedback(in_s)
    end
  end

  def ask_for_feedback(verbose = false)
    puts 'Compare the guess to your secret code; enter the number of bulls,'\
         ' then cows.'
    return unless verbose

    puts 'A bull is a pair of dots, one in the guess, one in your code, that '\
          "have the same colour and position.\nA cow is a pair that are the "\
          "same colour, but that haven't been counted as a bull or a cow."
  end

  def gets_without_return
    in_s = ''
    loop do
      exit(1) if (char = STDIN.noecho(&:getch)) == "\u0003"

      if char == "\177"
        print "\b \b"
        in_s.chop!
      else
        return in_s if /(\r|\n)/.match? char

        print char
        in_s += char
      end
    end
  end

  def parse_feedback(in_s)
    cattle = in_s.scan(/\d+/)
    return display_feedback(0, 0) if cattle.empty?

    cattle.map!(&:to_i)
    if cattle.length != 2 || cattle.any?(&:negative?) || cattle.sum > 4
      get_feedback(true)
    else display_feedback(cattle)
    end
  end
end

# Methods shared by all games where users guess (ie PvP and AI-follow)
class UserGuess < MastermindGame
  def guess(who)
    the_guess =
      Guess.new(who).check_len(@code.length).map_2_inds(COLOURS[0...@colours_i])
    return guess(who) unless the_guess

    @guesses << the_guess
    display_guess(the_guess)
    display_feedback(*the_guess.count_cattle)
  end
end

# Two users play eachother. The game keeps the code and judges guesses
class PvP < UserGuess
  def choose_secret_code(who)
    puts "#{who}, enter your secret code."
    unless (@code = parse_guess(STDIN.noecho(&:gets).strip.downcase))
      return choose_secret_code(who)
    end

    list_colours
  end
end

# AI chooses secret code randomly and user guesses it
class AIFollow < UserGuess
  def choose_secret_code(_who)
    @code = Array.new(slots) { rand(0...@colours_i) }
    list_colours
  end
end
