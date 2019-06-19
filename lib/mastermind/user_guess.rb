require_relative 'guess.rb'

# Methods shared by all games where users guess (ie PvP and AI-follow)
class UserGuess < MastermindGame
  def initialize(who, holes = 2, colours_len = 3, midgame_data = {})
    puts "#{who}, guess #{holes} colours, or just their first letters."\
      " Or type 'save' to save and close the game."
    super(holes, colours_len, midgame_data)
    @code = midgame_data['code']
    Guess.colours = COLOURS[0...@colours_len]
    reprint_previous_guesses unless midgame_data.empty?
  end

  def guess(who)
    the_guess = Guess.new
    return save_game if the_guess.save_instead?

    guessed_code = the_guess.check_len(@code.length).to_code
    return guess(who) unless guessed_code

    @guesses << guessed_code
    print "\r\e[1A\r" # Blank out line and carriage return
    guessed_code.print_pips(@max_guesses - @guesses.length)
    display_feedback(*guessed_code.count_cattle(@code))
  end

  def save_game
    puts
    print 'Saving game. '
    super.merge(code: @code)
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
    @code = Guess.new(STDIN.noecho(&:gets)).check_len(holes).to_code
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
