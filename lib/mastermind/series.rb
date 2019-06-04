# frozen_string_literal: true

require_relative 'games.rb'
require_relative 'helpers.rb'

# Creates series of games between 2 players or between player and computer
class MastermindSeries < Series
  def new_game(id_of_leader, midgame_data = {})
    who = @names[id_of_leader]
    @game = if @vs_ai
              if who == 'Computer'
                AILead.new(@holes, @colours, midgame_data)
              else AIFollow.new(who, @holes, @colours, midgame_data)
              end
            else PvP.new(who, @holes, @colours, midgame_data)
            end
  end

  def choose_secret(which_player)
    @game.choose_secret_code(@holes, @names[which_player])
  end

  def take_turn(which_player)
    midgame_data = @game.guess(@names[which_player])
    return save_game(midgame_data) if midgame_data.is_a? Hash

    over = @game.game_over?
    # In 'over', 1 -> guessed in time; 0 -> not
    @record << [which_player, over] if over
    over
  end

  def p
    p1_ws = @record.inject(0) do |wins, (which_player, result)|
      wins + (which_player ^ result)
    end
    super(p1_ws, @record.length - p1_ws)
  end
end
