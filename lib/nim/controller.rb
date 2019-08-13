%w[games.rb ../series_turn_based.rb series.rb
   ../controller_turn_based.rb].each { |f| require_relative(f) }

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
    print "How many heaps? (Or type 'r' for random)  "
    heaps = gets.chomp.to_i
    { heaps: heaps < 1 ? nil : [heaps, 50].min }
  end
end

if /main\.rb$/.match? $PROGRAM_NAME
  controller = Nim.new
  end_series ||= controller.do_a_round until end_series
end
