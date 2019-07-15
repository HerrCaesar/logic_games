# Shared methods between PvP and PvC games
class ChessGame < AdditiveStateGame
  PIECES = Hash.new(Pawn).merge!('K' => King, 'Q' => Queen, 'R' => Rook,
                                 'B' => Bishop, 'N' => Knight).freeze

  def initialize(midgame_data = {})
    @board = Board.new
    replay_old_moves unless midgame_data.empty?
    @board.p
  end

  def move(who, which)
    return propose_draw(who, colour) if @draw_proposed

    user_move(who, %w[w b][which])
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
    @board.p
  end

  private

  def replay_old_moves; end

  def user_move(who, colour)
    input = ask_for_move(who, colour)
    return input if input.is_a? Hash

    return @draw_proposed = true if input == '=' || /[Dd]raw/.match?(input)

    return @resignation = true if /[Rr]esign/.match? input

    move_hash = parse_for_castle(input, colour) ||
                parse_for_move(input) ||
                (return user_move(who, colour))
    @board.move(colour, move_hash) || user_move(who, colour)
  end

  def ask_for_move(who, colour)
    print "#{who} (#{colour}'s), describe describe your move in algebraic "\
      'notation. (Or save and close the game)  '
    return save_game if /([Ss]ave|[Cc]lose)/.match?(input = gets)

    input.strip
  end

  def parse_for_move(input)
    hsh = {}
    buff = nil
    while (c = input.slice!(0))
      case c
      when /[KQRBN]/
        hsh.empty? ? hsh[:piece] = PIECES[c] : hsh[:promotee] = PIECES[c]
      when /[a-h]/
        hsh[:file] = buff if buff
        buff = file_to_index(c)
      when /[1-8]/
        if buff
          hsh[:square] = hsh[:target]
          hsh[:target] = Vector[rank_to_index(c), buff]
          buff = nil
        else hsh[:rank] = rank_to_index(c)
        end
      end
    end
    hsh
  end

  def parse_for_castle(input, colour)
    case (spaces = input.scan(/[0oO]/).length)
    when 2, 3
      king = Vector[colour == 'w' ? 0 : 7, 4]
      { square: king }.merge(target: king + Vector[0, (spaces == 2 ? -2 : 3)])
    end
  end

  def file_to_index(char)
    char.ord - 97
  end

  def rank_to_index(char)
    char.to_I - 1
  end

  def grumble
    puts
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
