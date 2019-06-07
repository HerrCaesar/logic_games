# frozen_string_literal: true

require_relative 'series.rb'

# Controls Hangman series. Special because non-leading player chooses secret
class Hangman < Controller
  def initialize
    setup(HangmanSeries)
  end
end

if /main\.rb$/.match? $PROGRAM_NAME
  controller = Hangman.new
  end_series ||= controller.do_a_round until end_series
end
