# Computer plays against human in a game whose every states' every descending
# lineage is eventually childless
module AdditiveStatePvC
  def initialize(midgame_data = {})
    super
    reload_game_state_from_file unless midgame_data.empty?
  end

  private

  def ai_move(id)
    latest_move = @root_state.children[0][:game_state].latest_move
    @board.move(latest_move, id)
    latest_move
  end

  def move_root_state(latest_move)
    index = @root_state.children.index do |child|
      child[:game_state].latest_move == latest_move
    end
    @root_state = @root_state.children[index][:game_state]
  end
end

# Game where AI goes first
module AdditiveStateAILead
  private

  def pick_best_initial(moves)
    scores =
      Scores.new(moves.each_with_object([]) { |(_c, h), a| a << h[:score] })
    position = scores.normalise_scores.choose_wisely**2
    @root_state = moves[position][:game_state]
    position
  end
end
