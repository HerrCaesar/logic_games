# Shared methods between PvP and PvC games
class TicTacToeGame
  def initialize(midgame_data = {})
    if midgame_data.empty?
      @board = Board.new
      @moves_made = 0
    else
      @board = Board.new(midgame_data['board'])
      @moves_made = midgame_data['moves_made']
    end
    @board.p
  end

  def game_over?(who, which, changed_cell)
    if @board.game_won?(changed_cell)
      puts "#{who} wins!"
      return which
    elsif @board.all?
      puts 'Draw'
      return 2
    end
    false
  end

  def p
    @board.p
  end

  private

  def user_move(who, x_or_o)
    choice = ask_for_move(who, x_or_o)
    return choice if choice.is_a? Hash

    cell = parse_for_cell(choice)
    return user_move(who, x_or_o) unless
      cell && @board.yell_unless_cell_free?(cell)

    @board[cell] = x_or_o
    @moves_made += 1
    cell
  end

  def ask_for_move(who, x_or_o)
    print "#{who} (#{x_or_o}'s), describe (eg top left), or pick a number, "\
      '1-9. (Or save and close the game)  '
    return save_game(x_or_o) if /(save|close)/.match?(choice = gets.downcase)

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

  def save_game(x_or_o)
    return {} if @board.all?(&:nil?)

    {
      board: @board,
      moves_made: @moves_made,
      to_move: x_or_o == 'x' ? 0 : 1
    }
  end
end
