# frozen_string_literal: true

require_relative 'series.rb'
require_relative '../controller_turn_based.rb'

# Controls Nim series. Special because number of heaps needs setting
class Nim < TurnBased
  def initialize
    setup(NimSeries)
  end

  private

  def create_series(s_class)
    super(s_class, user_choose_heaps)
  end

  def whose_go
    @midgame ? @midgame ^ 1 : @id_of_leader
  end

  def user_choose_heaps
    puts "How many heaps? (Or type 'r' for random.)"
    heaps = gets.chomp.to_i
    { heaps: heaps < 1 ? nil : [heaps, 50].min }
  end
end

controller = Nim.new
end_series ||= controller.do_a_round until end_series
