# Shared methods between PvP and PvC games
class Connect4Game < AdditiveStateGame
  private

  def ask_for_move(who, id)
    print "#{who} (#{'●'.colorize(%i[blue red][id])}'s), where would you like"\
      ' to go? (Or save and close the game)  '
    return save_game(x_or_o) if /(save|close)/.match?(choice = gets.downcase)

    choice.scan(/\d/)[0]
  end

  def parse_for_position(choice)
    return choice - 1 if choice && (choice = choice.to_i).between?(1, 7)

    grumble
    false
  end

  def grumble
    puts 'Enter the column number from 1 to 7.'
  end

  def save_game(id)
    return {} if @board.all?(&:empty?)

    {
      board: @board,
      to_move: id
    }
  end
end
