# frozen_string_literal: true

require_relative './models/mastermind_series.rb'

# Controls Mastermind series. Special because # of holes & colours needs setting
class Mastermind < Controller
  def initialize
    setup(MastermindSeries)
  end

  private

  def create_series(s_class)
    super(s_class, choose_holes_and_colours)
  end

  def choose_holes_and_colours
    puts 'Enter how many holes and colours you want, or use the default (4, 6).'
    return default_holes_and_colours if (ins = gets.chomp.split).length != 2

    return default_holes_and_colours if ins.map!(&:to_i).any? { |int| int < 1 }

    if ins[1] > 8
      ins[1] = 8
      puts 'The game only supports 8 colours.'
    end

    { holes: ins[0], colours: ins[1] }
  end

  def default_holes_and_colours
    { holes: 4, colours: 6 }
  end
end

controller = Hangman.new
end_series ||= controller.do_a_round until end_series
