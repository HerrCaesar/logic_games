# frozen_string_literal: true

require 'colorize'
require 'io/console'

# Sets up the game and responds to guesses
class MastermindGame
  COLOURS = %i[red blue green yellow cyan white light_magenta black].freeze
  def initialize(holes = 2, colours_len = 3, midgame_data = {})
    @colours_len = colours_len
    @max_guesses = ((holes * colours_len)**0.6).round
    @guesses = midgame_data['guesses'] || []
    @code = midgame_data['code']
    @game_over = false
  end

  def game_over?
    @game_over
  end

  private

  def list_colours
    (0...@colours_len).each do |i|
      colour = COLOURS[i]
      print "#{colour.underline_first.colorize(colour)} "
    end
    puts
  end

  def display_guess(the_guess, guesses_taken = @guesses.length)
    dot = "\u25Cf".encode('utf-8')
    print "#{(@max_guesses - guesses_taken).to_s.rjust(2)}  "
    the_guess.each { |i| print "#{dot.colorize(COLOURS[i])}  " }
  end

  def display_feedback(bulls, cows, owrt_space = 0)
    puts "  #{bulls} bull#{s?(bulls)}, #{cows} cow#{s?(cows)}".ljust(owrt_space)
    # Game terminates when #game_over? runs if @game_over is truthy.
    # 1 -> guessed in time; 0 -> not
    @game_over = if bulls == @code.length
                   @game_over.nil? ? 0 : 1
                 else
                   return nil if @game_over.nil?

                   out_of_time? ? continue? : false
                 end
  end

  def s?(str)
    str == 1 ? '' : 's'
  end

  def out_of_time?
    @guesses.length >= @max_guesses
  end

  def continue?
    print "All the guesses (#{@max_guesses}) have been used up! "\
         'Do you want to continue anyway?'
    case gets
    when /[yY]/
      nil
    when /[nN]/
      0
    else continue?
    end
  end

  def save_game
    {
      code: @code,
      guesses: @guesses,
      game_over: @game_over
    }
  end
end

# User chooses secret code and AI guesses it
class AILead < MastermindGame
  def initialize(holes = 2, colours_len = 3, midgame_data = {})
    super
    @all_valid = generate_valid_codes(holes)
    @poss = midgame_data['poss'] || @all_valid.dup
    @all_cattle = midgame_data['all_cattle'] || []
    @code = Array.new(holes)
    reprint_previous_guesses unless midgame_data.empty?
  end

  def choose_secret_code(_holes, who)
    list_colours
    puts "#{who}, pick a secret code and remember it. Press enter when ready."
    gets
  end

  def guess(_who)
    the_guess = @guesses.empty? ? first_guess : pick_most_instructive_code
    @guesses << the_guess
    display_guess(the_guess)
    feedback(the_guess)
  end

  private

  def pick_most_instructive_code(choices = @all_valid)
    options_with_group_sizes = choices.map do |cd|
      [cd] << @poss.map { |x| x.count_cattle(cd) }
                   .each_with_object(Hash.new(0)) do |cttl, hsh|
                     hsh[cttl] += 1
                   end.values
    end
    get_best_option(options_with_group_sizes)
  end

  def generate_valid_codes(holes)
    (0...@colours_len).to_a.repeated_permutation(holes).to_a
  end

  def first_guess
    require_relative 'ofmg.rb'
    holes = @all_valid[0].length
    cached_generator = OPTIMAL_MOVE1_GENERATORS[[holes, @colours_len]]
    return generate_guess(cached_generator) if cached_generator

    find_optimal_first_move(holes)
  end

  def find_optimal_first_move(holes)
    partitions = holes.partition
    partitions.keep_if { |p| p.length <= @colours_len } if @colours_len < holes
    choices = partitions.map { |partition| generate_guess(partition) }
    pick_most_instructive_code(choices)
  end

  def generate_guess(generator)
    generator.each_with_index.each_with_object([]) do |(x, i), a|
      x.times { a << i }
    end
  end

  def feedback(the_guess, verbose = false)
    cattle = get_feedback(verbose)
    return cattle if cattle.is_a? Hash # ie contains save-data

    @all_cattle << cattle
    @poss.keep_if { |code| code.compare_cattle(the_guess, cattle) }
  end

  def get_feedback(verbose = false)
    ask_for_feedback(verbose)
    in_s = gets_without_return
    print "\b" * (padding = (verbose ? 267 : 39) + in_s.length)
    case in_s
    when /[hH]/
      get_feedback(true)
    when /[sScC]/
      save_game
    else parse_feedback(in_s, padding)
    end
  end

  def ask_for_feedback(verbose = false)
    print 'Enter the number of bulls, then cows'
    if verbose
      print '. A bull is a pair of dots, one in the guess, one in your code, '\
            'with the same colour and position. A cow is a pair that are the '\
            "same colour, but that haven't been counted as a bull or a cow"
    end
    print ':  '
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

  def parse_feedback(in_s, padding)
    return display_feedback(0, 0, padding) if in_s.empty?

    cattle = in_s.scan(/\d/).map(&:to_i)
    return get_feedback(true) if cattle.length != 2 ||
                                 cattle.any?(&:negative?) || cattle.sum > 4

    display_feedback(*cattle, padding)
    cattle
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

  def save_game
    puts
    print 'Saving game. '
    super.merge(poss: @poss, all_cattle: @all_cattle)
  end

  def reprint_previous_guesses
    list_colours
    @guesses.each_with_index do |guess, i|
      display_guess(guess, i + 1)
      cattle = @all_cattle[i]
      cattle ? display_feedback(*cattle) : feedback(guess)
    end
  end
end

# Methods shared by all games where users guess (ie PvP and AI-follow)
class UserGuess < MastermindGame
  def initialize(who, holes = 2, colours_len = 3, midgame_data = {})
    puts "#{who}, guess #{holes} colours, or just their first letters."\
      " Or type 'save' to save and close the game."
    super(holes, colours_len, midgame_data)
    reprint_previous_guesses unless midgame_data.empty?
  end

  def guess(who)
    the_guess = Guess.new
    return save_game if the_guess.save_instead

    the_guess.check_len(@code.length).map_2_inds!(COLOURS[0...@colours_len])
    return guess(who) unless the_guess

    @guesses << the_guess
    print "\r\e[1A\r"
    display_guess(the_guess)
    display_feedback(*the_guess.count_cattle(@code))
  end

  private

  def reprint_previous_guesses
    list_colours
    @guesses.each_with_index do |guess, i|
      puts
      display_guess(guess, i + 1)
      display_feedback(*guess.count_cattle(@code))
    end
  end
end

# Two users play eachother. The game keeps the code and judges guesses
class PvP < UserGuess
  def choose_secret_code(holes, who)
    puts "#{who}, enter your secret code."
    @code = Guess.new(STDIN.noecho(&:gets)).check_len(holes)
                 .map_2_inds(COLOURS[0...@colours_len])
    return choose_secret_code(holes, who) unless @code

    list_colours
  end
end

# AI chooses secret code randomly and user guesses it
class AIFollow < UserGuess
  def choose_secret_code(holes, _who)
    @code = Array.new(holes) { rand(0...@colours_len) }
    list_colours
  end
end