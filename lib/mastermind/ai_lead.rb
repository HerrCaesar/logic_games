require_relative 'codes.rb'

# User chooses secret code and AI guesses it
class AILead < MastermindGame
  def initialize(holes = 2, colours_len = 3, midgame_data = {})
    super
    generate_valid_codes(holes)
    @all_cattle = midgame_data['all_cattle'] || []
    reprint_previous_guesses unless midgame_data.empty?
  end

  def choose_secret_code(_holes, who)
    list_colours
    puts "#{who}, pick a secret code and remember it. Press enter when ready."
    gets
  end

  def guess(_who)
    the_guess = @guesses.empty? ? first_guess : @codes.most_instructive
    @guesses << the_guess
    the_guess.print_pips(@max_guesses - @guesses.length)
    feedback(the_guess)
  end

  private

  def generate_valid_codes(holes)
    @codes = Codes.new
    (0...@colours_len).to_a.repeated_permutation(holes) do |code|
      @codes << Code.new(code)
    end
    @codes.full
  end

  def first_guess
    require_relative 'ofmg.rb'
    holes = @codes[0].length
    cached_generator = OPTIMAL_MOVE1_GENERATORS[[holes, @colours_len]]
    return generate_guess(cached_generator) if cached_generator

    find_optimal_first_move(holes)
  end

  def find_optimal_first_move(holes)
    partitions = Codes.new(holes.partition)
    partitions.keep_if { |p| p.length <= @colours_len } if @colours_len < holes
    partitions.map! { |parti| code_from(parti) }.most_instructive(@codes)
  end

  def code_from(generator)
    generator.each_with_index.each_with_object(Code.new) do |(x, i), a|
      x.times { a << i }
    end
  end

  def feedback(the_guess, verbose = false)
    cattle = get_feedback(verbose)
    return cattle if cattle.is_a? Hash # ie contains save-data

    @all_cattle << cattle
    @codes.sort_by_cattle!(the_guess, cattle) unless @game_over
  end

  def get_feedback(verbose = false, owrt_prev = nil)
    ask_for_feedback(verbose, owrt_prev)
    in_s = gets_without_return
    print "\b" * (padding = (verbose ? 211 : 32) + in_s.length)
    case in_s
    when /([hH]|^$)/
      get_feedback(true)
    when /[sScC]/
      save_game
    else parse_feedback(in_s, padding)
    end
  end

  def ask_for_feedback(verbose, owrt_prev)
    print "Enter the number of #{B}, then #{C}"
    if verbose
      print ". A #{B} is a pair of dots, one in the guess, one in your code, "\
            "with the same colour and position. A #{C} is a pair that are the "\
            "same colour, but that haven't been counted as a #{B} or a #{C}"
    end
    print ':  '
    [' ', "\b"].each { |c| owrt_prev.times { print c } } if owrt_prev
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
    cattle = in_s.scan(/\d/).map(&:to_i)
    return get_feedback(true, in_s.length) if
      cattle.length != 2 || cattle.any?(&:negative?) || cattle.sum > 4

    display_feedback(*cattle, padding)
    cattle
  end

  def save_game
    puts
    print 'Saving game. '
    super.merge(poss: @poss, all_cattle: @all_cattle)
  end

  def reprint_previous_guesses
    list_colours
    @guesses.each_with_index do |guess, i|
      guess.print_pips(@max_guesses - i)
      cattle = @all_cattle[i]
      if cattle
        display_feedback(*cattle)
        @codes.sort_by_cattle!(guess, cattle)
      else feedback(guess)
      end
    end
  end
end
