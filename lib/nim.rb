# TODO: saves
# frozen_string_literal: true

require_relative './models/nim_and_ttt_series.rb'

# Controls Nim series. Special because number of heaps needs setting
class Nim < Controller
  def initialize
    setup(NimSeries)
  end

  private

  def create_series(s_class)
    super(s_class, user_choose_heaps)
  end

  def user_choose_heaps
    puts "How many heaps? (Or type 'r' for random.)"
    heaps = gets.chomp.to_i
    { heaps: heaps < 1 ? nil : [heaps, 50].min }
  end

  def play_round
    whose_go = @leading_player ^= 1
    game_over ||= @series.take_turn(whose_go ^= 1) until game_over
    game_over == 'saved' || !continue_to_next_game?
  end
end

controller = Nim.new
end_series ||= controller.do_a_round until end_series
