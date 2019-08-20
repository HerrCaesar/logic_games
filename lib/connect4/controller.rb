%w[../additive_state_controller.rb board.rb game_state.rb game.rb
   series.rb].each { |f| require_relative(f) }

# Controls Connect 4 series
class Connect4 < Additive
  def initialize
    setup(Connect4Series)
  end
end

if /main\.rb$/.match? $PROGRAM_NAME
  controller = Connect4.new
  end_series ||= controller.do_a_round until end_series
end
