# Computer creates, prints and plays against human on tic-tac-toe board
class PvC < TicTacToeGame
  private

  def ai_move(id)
    @moves_made += 1
    puts "\nComputer's move:"
    return only_just_started(id) if @moves_made < 4

    return if !none_two_thirds_done(id) || !none_one_third_done(id)

    draw(@board.first_available_cell, id)
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
      return draw(2, id) if [1, 2, 5].all? { |x| @board.free?(x) }

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
          return draw(cell, id) if @board.free?(cell)
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
    just_ai.find_intersects.each { |cell| return draw(cell, id) }
  end

  def no_user_one_third(just_ai, id)
    u_insects = get_lines_summing(other(id)).find_intersects
    return true if u_insects.empty?

    line_min_sects = just_ai.min { |a, b| a & u_insects <=> b & u_insects }
    on_enemy_lines = (line_min_sects & u_insects)[0] || line_min_sects[0]
    return true unless on_enemy_lines

    draw(on_enemy_lines, id)
  end

  def get_lines_summing(sum)
    @line_sums.each_with_index.with_object(Lines.new) do |(l_s, i), lns|
      lns << Line.new(i).select { |cell| @board.free?(cell) } if l_s == sum
    end
  end

  def other(id)
    (id - 3)**2
  end
end

# Game where AI gets to go first
class AILead < PvC
  def move(who, _which = nil)
    return ai_move(1) if @moves_made.even?

    user_move(who, 4)
  end
end

# Game where user gets to go first and AI second
class AIFollow < PvC
  def move(who, _which = nil)
    return ai_move(4) if @moves_made.odd?

    user_move(who, 1)
  end
end
