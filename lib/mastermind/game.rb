require 'colorize'
require 'io/console'
require_relative 'code.rb'

# Sets up the game and responds to guesses
class MastermindGame
  COLOURS = %i[red blue green yellow cyan white light_magenta black].freeze
  B = '●'.colorize(:red)
  C = '●'.colorize(:white)

  def initialize(holes = 2, colours_len = 3, midgame_data = {})
    @colours_len = colours_len
    @max_guesses = ((holes * colours_len)**0.6).round
    @guesses = (midgame_data['guesses'] || []).map { |g| Code.new(g) }
    @game_over = false
    Code.colours = COLOURS[0...@colours_len]
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

  def display_feedback(bulls, cows, owrt_space = 0)
    b = B + ' '
    c = C + ' '
    puts "  #{b * bulls + c * cows}" + ' ' * owrt_space
    test_game_over(bulls)
  end

  def test_game_over(bulls)
    # Game terminates when #game_over? runs if @game_over is truthy.
    # 1 -> guessed in time; 0 -> not
    @game_over = if bulls == (@code || @codes[0]).length
                   @game_over.nil? ? 0 : 1
                 else
                   return nil if @game_over.nil?

                   out_of_time? ? continue? : false
                 end
  end

  def out_of_time?
    @guesses.length >= @max_guesses
  end

  def continue?
    print "All the guesses (#{@max_guesses}) have been used up! "\
         'Do you want to continue anyway?   '
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
      guesses: @guesses,
      game_over: @game_over
    }
  end
end
