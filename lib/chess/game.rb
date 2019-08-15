# Shared methods between PvP and PvC games
class ChessGame
  def initialize(midgame_data = {})
    @board = Board.new
    @graveyard = Graveyard.new
    @record = []
    replay_old_moves unless midgame_data.empty?
    @board.p
  end

  def move(who, which)
    colour = %w[w b][which]
    return propose_draw(who, colour) if @draw_proposed

    user_move(who, colour)
  end

  def game_over?(who, which)
    if @resignation || @board.checkmate?
      puts "#{who} wins!"
      return which
    elsif @draw_agreed || @board.stalemate?
      puts 'Draw'
      return 2
    end
    false
  end

  def p
    @graveyard.p('w')
    @board.p
    @graveyard.p('b')
  end

  private

  def replay_old_moves; end

  def user_move(who, colour)
    case (move = MoveAlgebra.new(who, colour))
    when /([sS][aA][vV][eE]|[cC][lL][oO][sS][eE])/
      return save_game
    when /(=|[dD][Rr][aA][wW])/
      return (@draw_proposed = true)
    when /[rR][eE][sS][iI][gG][nN]/
      return (@resignation = true)
    end
    try(move, colour) || user_move(who, colour)
  end

  def try(move, colour)
    move_hash = move.to_move_hash || (return false)
    last_move = @record.empty? ? nil : @record.last.to_move_hash
    return false unless (taken = @board.move(colour, move_hash, last_move))

    @graveyard.add(taken) if taken.is_a?(Piece)
    true
  end

  def propose_draw(who, colour)
    print "#{who} (#{colour}'s), do you agree to a draw? (Or save and close "\
      'the game)  '
    return save_game if /(save|close)/.match?(input = gets.downcase)

    @draw_agreed = true if /y/.match? input
  end

  def save_game
    {
      record: @record,
      draw_proposed: @draw_proposed
    }
  end
end
