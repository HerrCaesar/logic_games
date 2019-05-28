# TODO: store previous guesses so we can print them all on reload
require 'colorize'

# Sets up the game and responds to guesses
class Game
  def initialize(slots = 2, cols = 3)
    @colours =
      %i[red blue green yellow cyan white light_magenta black][0...cols]
    @board = Array.new(slots) { @colours.sample }
    @guess_count = 0
    list_colours
  end

  def guess(who)
    return unless (guesses = parse_guess(ask_for_guess(who)))

    @guess_count += 1
    display_guess(guesses)
    bulls, cows = count_cattle(guesses)
    puts "  #{bulls} bull#{s?(bulls)}, #{cows} cow#{s?(cows)}"
    bulls == @board.length
  end

  private

  def list_colours
    @colours.each { |col| print "#{col.to_s.underline_first.colorize(col)} " }
    puts
  end

  def ask_for_guess(who)
    puts "#{who}, guess by typing colours, or just their first letters."
    gets.strip
  end

  def count_cattle(guesses)
    brd = @board.dup
    bulls = get_bulls(guesses, brd)
    bulls.reverse.each { |i| [brd, guesses].each { |arr| arr.delete_at(i) } }
    [bulls.length, count_cows(guesses, brd)]
  end

  def parse_guess(long_form)
    guesses = long_form.downcase.split
    if guesses.length != @board.length
      puts "You need to make #{@board.length} guesses."
      false
    else
      match_guesses_to_cols(guesses)
    end
  end

  def match_guesses_to_cols(guesses)
    guesses.map do |guess|
      match = match_guess(guess)
      return false unless match

      match
    end
  end

  def match_guess(guess)
    @colours.each do |col|
      return col if col[0] == guess[0]
    end
    puts "Can't match #{x} to an available colour."
    false
  end

  def display_guess(guesses)
    dot = "\u25Cf".encode('utf-8')
    print "\r\e[1A\r#{@guess_count.to_s.rjust(3, ' ')}  "
    guesses.each { |col| print "#{dot.colorize(col)}  " }
  end

  def get_bulls(guesses, brd)
    brd.each_with_index.inject([]) do |bullish, (col, slot)|
      col == guesses[slot] ? bullish << slot : bullish
    end
  end

  def count_cows(guesses, brd)
    brd.inject(0) do |count, col|
      where = guesses.index(col)
      guesses.delete_at(where) if where
      count + (where ? 1 : 0)
    end
  end

  def s?(str)
    str == 1 ? '' : 's'
  end
end
