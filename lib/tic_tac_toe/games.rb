# Shared methods between PvP and PvC games
class TicTacToeGame
  def initialize(midgame_data = {})
    if midgame_data.empty?
      @board = Array.new(9) { 0 }
      @line_sums = Array.new(8) { 0 }
      @moves_made = 0
    else
      @board = midgame_data['board']
      @line_sums = midgame_data['line_sums']
      @moves_made = midgame_data['moves_made']
    end
    p
  end

  def game_over?(which, who)
    if ([3, 12] & @line_sums).any?
      puts "#{who} wins!"
      return which
    elsif @moves_made == 9
      puts 'Draw'
      return 2
    end
    false
  end

  def p
    @board.each_with_index do |x, i|
      print [' ', 'x', 'o'][Integer.sqrt(x)] + (i % 3 == 2 ? "\n" : '|')
    end
  end

  private

  def user_move(player_id, who)
    choice = ask_for_move(player_id, who)
    return choice if choice.is_a? Hash

    cell = parse_for_cell(choice)
    return user_move(player_id, who) unless cell && cell_empty?(cell)

    draw(cell, player_id)
    @moves_made += 1
  end

  def ask_for_move(player_id, who)
    print "#{who} (#{player_id == 1 ? 'X' : 'O'}'s'), describe (eg top left),"\
          ' or pick a number, 1-9. '
    puts 'Or save and close the game.'
    return save_game(player_id) if /(save|close)/.match?(choice = gets.downcase)

    choice.strip.split.map { |x| x[0] }
  end

  def parse_for_cell(choice)
    case choice.length
    when 1
      parse_for_number(choice)
    when 2
      parse_for_descrip(choice)
    else puts 'Enter two words, or the cell number from 1 to 9.'
    end
  end

  def draw(cell, player_id)
    @board[cell] = player_id
    arr = [cell / 3, cell % 3 + 3]
    arr << 6 if (cell % 4).zero?
    arr << 7 if [2, 4, 6].include?(cell)
    arr.each { |line| @line_sums[line] += player_id }
    nil
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

  def parse_for_descrip(in_a)
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

  def cell_empty?(cell)
    return true if @board[cell].zero?

    puts 'This square is taken!'
    false
  end

  def save_game(player_id)
    {
      board: @board,
      moves_made: @moves_made,
      line_sums: @line_sums,
      to_move: [1, 4].index(player_id)
    }
  end
end

# Takes moves from two players, displays them and tests win-conditions
class PvP < TicTacToeGame
  def move(which, who)
    user_move([1, 4][which], who)
  end
end

# Computer creates, prints and plays against human on tic-tac-toe board
class PvC < TicTacToeGame
  private

  def ai_move(id)
    @moves_made += 1
    puts "\nComputer's move:"
    return only_just_started(id) if @moves_made < 4

    return if !none_two_thirds_done(id) || !none_one_third_done(id)

    first_available_cell
  end

  def only_just_started(id)
    case @moves_made - 1
    when 0
      # Top-left first
      draw(0, id)
    when 1
      # Take middle if empty, else top left
      @board[4].zero? ? draw(4, id) : draw(2, id)
    when 2
      third_move(id)
    end
  end

  def third_move(id)
    if @board[4].zero? # Middle free
      # North East empty -> top-right
      return draw(2, id) if [1, 2, 5].all? { |x| @board[x].zero? }

      # else -> bottom-left
      draw(6, id)
    else
      # Middle taken -> bottom-right
      draw(8, id)
    end
  end

  def none_two_thirds_done(id)
    # Look for line one away from completion (ai's then opponent's)
    [2 * id, 2 * other(id)].each do |sum|
      get_lines_summing(sum).each do |line|
        line.each do |cell|
          return draw(cell, id) if @board[cell].zero?
        end
      end
    end
  end

  def none_one_third_done(id)
    # Look for two lines with only one mark in that intersect on an empty. If
    # yours, go on empty intersection. If opponent's, find your single-mark line
    # with fewest intersections and take the square with most intersections.
    just_ai = get_lines_summing(id)
    return unless no_ai_one_third(just_ai, id)

    no_user_one_third(just_ai, id)
  end

  def no_ai_one_third(just_ai, id)
    find_intersects(just_ai).each { |cell| return draw(cell, id) }
  end

  def no_user_one_third(just_ai, id)
    u_insects = find_intersects(get_lines_summing(other(id)))
    line_min_sects = just_ai.min { |a, b| a & u_insects <=> b & u_insects }
    on_enemy_lines = (line_min_sects & u_insects)[0] || line_min_sects[0]
    return true unless on_enemy_lines

    draw(on_enemy_lines, id)
  end

  def first_available_cell
    @board.each_with_index { |x, i| return draw(i, 1) if x.zero? }
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

  def get_lines_summing(sum)
    @line_sums.each_with_index.inject([]) do |arr, (l_s, i)|
      l_s == sum ? arr << get_line(i).select { |cell| @board[cell].zero? } : arr
    end
  end

  def find_intersects(lines)
    len = lines.length
    shared = []
    (0...len - 1).to_a.each do |l1|
      (l1 + 1..len - 1).to_a.each { |l2| shared.push(*lines[l1] & lines[l2]) }
    end
    shared
  end

  def count_occurences(cell, lines)
    lines.count { |line| line.include? cell }
  end

  def other(id)
    (id - 3)**2
  end
end

# Game where AI gets to go first
class AILead < PvC
  def move(_which, who)
    return ai_move(1) if @moves_made.even?

    user_move(4, who)
  end
end

# Game where user gets to go first and AI second
class AIFollow < PvC
  def move(_which, who)
    return ai_move(4) if @moves_made.odd?

    user_move(1, who)
  end
end
