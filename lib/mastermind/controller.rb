require_relative 'series.rb'

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
    print 'How many holes & colours do you want? (Or use the default: 4 & 6)  '
    return default_holes_and_colours if (in_s = gets.chomp.split).length != 2

    return default_holes_and_colours if in_s.map!(&:to_i).any? { |int| int < 1 }

    if in_s[1] > 8
      in_s[1] = 8
      puts 'The game only supports 8 colours.'
    end

    { holes: in_s[0], colours: in_s[1] }
  end

  def default_holes_and_colours
    { holes: 4, colours: 6 }
  end
end

if /main\.rb$/.match? $PROGRAM_NAME
  controller = Mastermind.new
  end_series ||= controller.do_a_round until end_series
end
