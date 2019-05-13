# Shared methods between PvP and PvC games
class Game
  @record = []
  class << self; attr_accessor :record, :users end

  def initialize
    @board = Array.new(9) { 0 }
    @line_sums = Array.new(8) { 0 }
    @moves_made = 0
    display_board
    play_game
  end

  def display_board
    xo_arr = (Game.users[:o] == 'Computer' ? [' ', 'o', 'x'] : [' ', 'x', 'o'])
    @board.each_with_index do |x, i|
      print xo_arr[[0, 1, 4].index(x)]
      print i % 3 == 2 ? "\n" : '|'
    end
  end

  def user_choose(user_flag = 4)
    1.times do
      puts 'Describe (eg top left), or pick a number, 1-9:'
      in_arr = gets.chomp.split.map { |x| x[0].downcase }
      case in_arr.length
      when 1
        if in_arr[0] == 'm'
          cel = 4
        elsif in_arr[0].to_i.between?(1, 9)
          cel = in_arr[0].to_i - 1
        else
          puts 'Enter two words, or the cell number from 1 to 9.'
          redo
        end
      when 2
        if %w[t b].include?(in_arr[1]) || %w[l r].include?(in_arr[0])
          in_arr[1], in_arr[0] = in_arr
        end
        begin
          in_arr.map! { |letter| %w[t l m c b r].index(letter) / 2 }
        rescue NoMethodError
          puts 'Did you mean to write that?'
          redo
        else
          cel = in_arr[0] * 3 + in_arr[1]
        end
      else
        puts 'Enter two words, or the cell number from 1 to 9.'
        redo
      end
      unless @board[cel].zero?
        puts 'This square is taken!'
        redo
      end
      move(cel, user_flag)
    end
  end

  def move(cel, player)
    @board[cel] = player
    arr = [cel / 3, cel % 3 + 3]
    arr << 6 if (cel % 4).zero?
    arr << 7 if [2, 4, 6].include?(cel)
    arr.each { |line| @line_sums[line] += player }
  end

  def game_over?
    !([3, 12] & @line_sums).empty?
  end

  def report_stats
    p_one = Game.users[:x]
    p_two = Game.users[:o]
    print "#{count_outcomes(p_one)} #{p_one} wins; "
    print "#{count_outcomes('draw')} draws; "
    print "#{count_outcomes(p_two)} #{p_two} wins. "
  end

  def count_outcomes(outcome)
    Game.record.count { |game| game == outcome }
  end
end

# Computer creates, prints and plays against human on tic-tac-toe board
class PvC < Game
  def initialize
    if Game.record.empty?
      1.times do
        players = %w[Player Computer]
        puts 'Do you want to go first?'
        players.reverse! if gets =~ /[nN]/
        @next_to_move = players[0]
        Game.users = { x: players[0], o: players[1] }
      end
    else
      @next_to_move = Game.users[Game.record.length.even? ? :x : :o]
    end
    super
  end

  def play_game
    loop do
      @next_to_move == 'Player' ? user_choose : ai_choose
      display_board
      if game_over?
        Game.record = Game.record << 'Computer'
        return report_stats
      end

      @moves_made += 1
      if @moves_made == 9
        puts 'Draw'
        Game.record = Game.record << 'draw'
        return report_stats
      end

      @next_to_move = (@next_to_move == 'Computer' ? 'Player' : 'Computer')
    end
  end

  def ai_choose
    puts "\nComputer's move:"
    case @moves_made
    when 0
      # Top-left first
      return move(0, 1)
    when 1
      # Take middle if empty, else top left
      return @board[4].zero? ? move(4, 1) : move(2, 1)
    when 2
      if @board[4].zero? # Middle free
        # North East empty -> top-right
        return move(2, 1) if [1, 2, 5].all? { |x| @board[x].zero? }

        # else -> bottom-left
        return move(6, 1)
      end
      # Middle taken -> bottom-right
      return move(8, 1)
    end
    # Look for line one away from completion (ai's then opponent's)
    [2, 8].each do |sum|
      pick_lines_summing(sum).each do |line|
        get_line(line).each { |x| return move(x, 1) if @board[x].zero? }
      end
    end
    # Look for lines with only one mark in. If yours, go on empty intersection;
    # or if opponent's, go on empty, non-intersection square in one of lines.
    sum_to1 = pick_lines_summing(1)
    find_intersects(sum_to1).each { |x| return move(x, 1) if @board[x].zero? }
    intersect4s = pick_lines_summing(4)
    sum_to1.each do |line|
      get_line(line).each do |cel|
        return move(cel, 1) if @board[cel].zero? && !intersect4s.include?(cel)
      end
    end

    first_available_cel
  end

  def get_line(line)
    case line
    when 0..2 # Rows
      (line * 3..line * 3 + 2).to_a
    when 3..5 # Columns
      [line - 3, line, line + 3]
    when 6 # Back-slash diagonal
      [0, 4, 8]
    else # Forward-slash diagonal
      [2, 4, 6]
    end
  end

  def pick_lines_summing(sum)
    @line_sums.each_with_index.inject([]) { |a, (l, i)| l == sum ? a << i : a }
  end

  def find_intersects(lines)
    len = lines.length
    lines.map! { |l| get_line(l) }
    shared = []
    (0...len - 1).to_a.each do |l1|
      (l1 + 1..len - 1).to_a.each { |l2| shared.push(*lines[l1] & lines[l2]) }
    end
    shared
  end

  def first_available_cel
    @board.each_with_index { |x, i| return move(i, 1) if x.zero? }
  end
end

# Takes moves from two players, displays them and tests win-conditions
class PvP < Game
  def initialize
    if Game.record.length.zero?
      puts 'Who wants to go first?'
      @next_to_move = gets.chomp.capitalize
      Game.users = { x: @next_to_move }
    else
      @next_to_move = Game.record.length.even? ? Game.users[:x] : Game.users[:o]
    end
    super
  end

  def play_game
    loop do
      print "#{@next_to_move}... "
      user_choose(Game.users.key(@next_to_move) == :x ? 1 : 4)
      display_board
      if game_over?
        Game.record = Game.record << @next_to_move
        report_stats
        return
      end

      @moves_made += 1
      if @moves_made == 9
        puts 'Draw'
        Game.record = Game.record << 'draw'
        report_stats
        return
      end

      if Game.users.length == 1
        loop do
          puts "And what's the second player's name?"
          proposed_name = gets.chomp.capitalize
          if proposed_name == @next_to_move
            puts 'A different name, please'
          else
            @next_to_move = proposed_name
            break
          end
        end
        Game.users = Game.users.merge(o: @next_to_move)
      else
        @next_to_move =
          Game.users[:o] == @next_to_move ? Game.users[:x] : Game.users[:o]
      end
    end
  end
end

c_or_p = nil
loop do
  puts '1-player (1) or 2-player (2)?'
  c_or_p = [1, 2].index(gets.chomp.to_i)
  break if c_or_p
end

loop do
  c_or_p.zero? ? PvC.new : PvP.new
  puts 'Rematch?'
  break unless gets =~ /[yY]/
end
