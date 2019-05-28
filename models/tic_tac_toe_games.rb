# TODO: midgames saves
# Shared methods between PvP and PvC games
class TicTacToeGame
  def initialize(midgame_data)
    @board = Array.new(9) { 0 }
    p
  end

  def p
    @board.each_with_index do |x, i|
      print [' ', 'x', 'o'][Integer.sqrt(x)] + (i % 3 == 2 ? "\n" : '|')
    end
  end

  def user_move(player_id)
    case ask_for_move.length
    when 1
      return user_move(player_id) unless (cel = parse_for_number(in_a))
    when 2
      return user_move(player_id) unless (cel = parse_for_description(in_a))
    else
      puts 'Enter two words, or the cell number from 1 to 9.'
      return user_move(player_id)
    end
    cell_empty?(cel) ? draw(cel, player_id) : user_move(player_id)
  end

  def game_over?(which, who)
    if ([3, 12] & @line_sums).any?
      puts "#{who == '_computer' ? 'Computer' : who} wins!"
      return which
    elsif @moves_made == 9
      puts 'Draw'
      return 2
    end
    false
  end

  private

  def draw(cel, player_id)
    @board[cel] = player_id
    arr = [cel / 3, cel % 3 + 3]
    arr << 6 if (cel % 4).zero?
    arr << 7 if [2, 4, 6].include?(cel)
    arr.each { |line| @line_sums[line] += player_id }
  end

  def ask_for_move
    puts 'Describe (eg top left), or pick a number, 1-9:'
    gets.chomp.split.map { |x| x[0].downcase }
  end

  def parse_for_number(in_a)
    if in_a[0] == 'm'
      4
    elsif in_a[0].to_i.between?(1, 9)
      in_a[0].to_i - 1
    else
      puts 'Enter two words, or the cell number from 1 to 9.'
      false
    end
  end

  def parse_for_description(in_a)
    in_a.reverse! if %w[t b].include?(in_a[1]) || %w[l r].include?(in_a[0])
    begin
      in_a.map! { |letter| %w[t l m c b r].index(letter) / 2 }
    rescue NoMethodError
      puts 'Did you mean to write that?'
      false
    else
      in_a[0] * 3 + in_a[1]
    end
  end

  def cell_empty?(cel)
    if @board[cel].zero?
      true
    else
      puts 'This square is taken!'
      false
    end
  end
end

# Takes moves from two players, displays them and tests win-conditions
class PvP < Game
  def move(which, who)
    print "#{who}... "
    user_move([1, 4][which])
  end
end

# Computer creates, prints and plays against human on tic-tac-toe board
class PvC < TicTacToeGame
  def initialize(midgame_data)
    @line_sums = Array.new(8) { 0 }
    @moves_made = 0
    super
  end

  private

  def ai_move(id)
    puts "\nComputer's move:"
    case @moves_made
    when 0
      # Top-left first
      return draw(0, id)
    when 1
      # Take middle if empty, else top left
      return @board[4].zero? ? draw(4, id) : draw(2, id)
    when 2
      if @board[4].zero? # Middle free
        # North East empty -> top-right
        return draw(2, id) if [1, 2, 5].all? { |x| @board[x].zero? }

        # else -> bottom-left
        return draw(6, id)
      end
      # Middle taken -> bottom-right
      return draw(8, id)
    end
    # Look for line one away from completion (ai's then opponent's)
    [2 * id, 2 * (id - 3)**2].each do |sum|
      pick_lines_summing(sum).each do |line|
        get_line(line).each { |x| return draw(x, id) if @board[x].zero? }
      end
    end
    # Look for lines with only one mark in. If yours, go on empty intersection;
    # or if opponent's, go on empty, non-intersection square in one of lines.
    just_ai = pick_lines_summing(id)
    find_intersects(just_ai).each { |x| return draw(x, id) if @board[x].zero? }

    just_user = pick_lines_summing((id - 3)**2)
    just_ai.each do |line|
      get_line(line).each do |cel|
        return draw(cel, id) if @board[cel].zero? && !just_user.include?(cel)
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
    @board.each_with_index { |x, i| return draw(i, 1) if x.zero? }
  end
end

# Game where AI gets to go first
class AILead < PvC
  def move(_which, who)
    return ai_move(1) if @moves_made.even?

    print "#{who}... "
    user_move(4)
  end
end

# Game where user gets to go first and AI second
class AIFollow < PvC
  def move(_which, who)
    return ai_move(4) if @moves_made.odd?

    print "#{who}... "
    user_move(1)
  end
end
