# Holds names of user(s) and computer (if playing)
class Names < Array
  def initialize(vs_ai)
    super(organize_teams(vs_ai))
  end

  def choose_second(vs_ai)
    return add_computer if vs_ai

    print "What's player 2's name?  "
    push((name = gets.strip.capitalize).empty? ? 'Player 2' : name)
  end

  private

  def organize_teams(vs_ai)
    print "What's your name?  "
    name = gets.strip.capitalize
    if name == 'Computer' && vs_ai
      puts "Hey that's my name! get your own."
      return organize_teams(vs_ai)
    end
    [name.empty? ? 'Player 1' : name]
  end

  def add_computer
    push 'Computer'
    print 'Do you want to go first to begin with?  '
    reverse! if /[nN]/.match?(gets)
  end
end
