# Shared methods between PvP and PvC games
class TicTacToeGame < AdditiveStateGame
  private

  def ask_for_move(who, x_or_o)
    print "#{who} (#{x_or_o}'s), describe (eg top left), or pick a number, "\
      '1-9. (Or save and close the game)  '
    return save_game(x_or_o) if /(save|close)/.match?(choice = gets.downcase)

    choice.strip.split.map { |x| x[0] }
  end

  def parse_for_position(in_a)
    case in_a.length
    when 1
      parse_for_number(in_a)
    when 2
      parse_for_descrip(in_a)
    else grumble
    end
  end

  def parse_for_number(in_a)
    if in_a[0] == 'm'
      4
    elsif (choice = in_a[0].to_i).between?(1, 9)
      choice - 1
    else
      grumble
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

  def grumble
    puts 'Enter two words, or the cell number from 1 to 9.'
  end

  def save_game(x_or_o)
    return {} if @board.all?(&:nil?)

    {
      board: @board,
      to_move: x_or_o == 'x' ? 0 : 1
    }
  end
end
