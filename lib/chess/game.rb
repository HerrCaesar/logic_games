# Shared methods between PvP and PvC games
class ChessGame
  def initialize(midgame_data = {})
    @board = Board.new
    @graveyard = Graveyard.new
    @record = midgame_data['record'] || []
    @draw_proposed = midgame_data['draw_proposed']
    replay_old_moves unless midgame_data.empty?
    @board.p
  end

  def move(who, _which)
    @moving_colour = %w[w b][@record.length % 2]
    return propose_draw(who, @moving_colour) if @draw_proposed

    (success = user_move(who, @moving_colour)) until success
    success
  end

  def game_over?(who, which)
    if @resignation || @board.checkmate?(@moving_colour)
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

  def replay_old_moves
    @record.each_with_index do |move_str, i|
      move_alg = MoveAlgebra.new(colour: %w[w b][i % 2], value: move_str)
      @board.make_move(move_alg.to_move)
    end
  end

  def user_move(who, colour)
    case (move_alg = MoveAlgebra.new(who: who, colour: colour)).downcase
    when /(save|close)/
      return save_game
    when /(=|draw)/
      return (@draw_proposed = true)
    when /resign/
      return (@resignation = true)
    end
    try(move_alg)
  end

  def try(move_alg)
    move = move_alg.to_move || (return false)
    move.last_move = @record.last unless @record.empty?
    return false unless (taken = @board.make_move(move))

    @graveyard.add(taken) if taken.is_a?(Piece)
    @record << move.to_move_algebra
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
