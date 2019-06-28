# Shared methods between PvP and PvC games
class AdditiveStateGame
  def initialize(midgame_data = {})
    @board =
      (midgame_data.empty? ? Board.new : Board.new(midgame_data['board']))
    @board.p
  end

  def game_over?(who, which, changed_position)
    if @board.game_won?(changed_position)
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

  def user_move(who, id)
    choice = ask_for_move(who, id)
    return choice if choice.is_a? Hash

    position = parse_for_position(choice)
    return user_move(who, id) unless
      position && @board.yell_unless_free?(position)

    @board.move(position, id)
    position
  end
end
