# Shared methods between PvP and PvC games
class TicTacToeGame
  def initialize(midgame_data = {})
    if midgame_data.empty?
      @board = Board.new(9) { 0 }
      @line_sums = Array.new(8) { 0 }
      @moves_made = 0
    else
      @board = Board.new(midgame_data['board'])
      @line_sums = midgame_data['line_sums']
      @moves_made = midgame_data['moves_made']
    end
    @board.p
  end

  def game_over?(who, which)
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
    @board.p
  end

  private

  def user_move(who, player_id)
    choice = ask_for_move(who, player_id)
    return choice if choice.is_a? Hash

    cell = parse_for_cell(choice)
    return user_move(who, player_id) unless
      cell && @board.yell_unless_cell_free?(cell)

    draw(cell, player_id)
    @moves_made += 1
  end

  def ask_for_move(who, player_id)
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

  def save_game(player_id)
    {
      board: @board,
      moves_made: @moves_made,
      line_sums: @line_sums,
      to_move: [1, 4].index(player_id)
    }
  end
end
