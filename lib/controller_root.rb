# frozen_string_literal: true

# General formula for running a series of games
class Controller
  def do_a_round
    setup_round
    play_round
  end

  private

  def setup(s_class, options = nil, offer_load = true)
    if (saved = saved_games_available) && offer_load && load_series?
      return setup(s_class, options, false) unless (old_game = pick_game(saved))

      load_existing_series(old_game)
    else
      create_series(s_class)
    end
  end

  def setup_round
    @series.new_game(@id_of_leader) unless @midgame
    # Non-leading player chooses secret in hangman & mastermind; otherwise nil.
    @series.choose_secret(@id_of_leader ^ 1)
  end

  def play_round
    game_over ||= @series.take_turn(@id_of_leader) until game_over
    game_over == 'saved' || !continue_to_next_game?
  end

  def saved_games_available
    return false unless File.exist?('saved.json')

    require 'json'
    JSON.parse(File.read('saved.json')).select do |_k, game|
      game['game'] == self.class.name
    end.sort.to_h
  end

  def load_series?
    puts 'Start new game or load from file?'
    gets =~ /[LlFf]/
  end

  def pick_game(saved)
    puts 'Which game do you want to load? (or just press enter to cancel)'
    saved.each_with_index { |(key, _value), index| puts "(#{index}) #{key}" }
    ins = gets.chomp
    return false if ins.empty?

    if /^\d+$/.match? ins
      saved[saved.keys[ins.to_i]] || pick_game(saved)
    else
      saved[ins] || pick_game(saved)
    end
  end

  def load_existing_series(s_class, old_game)
    # Get index of next player due to guess
    @id_of_leader = old_game['record'].length % 2
    @series =
      s_class.new(*old_game.slice('vs_ai', 'names', 'options', 'record').values)
    return unless midgame?(old_game['midgame_data'])

    @series.new_game(@id_of_leader, old_game['midgame_data'])
  end

  def create_series(s_class, options = {})
    names = organize_teams
    vs_ai = vs_ai?
    @id_of_leader = 0
    names = set_second_name(vs_ai, names)
    @series = s_class.new(vs_ai, names, options)
  end

  def vs_ai?
    puts '1-player (1) or 2-player (2)?'
    /1/.match? gets
  end

  def organize_teams
    puts "What's your name?"
    [(gets.strip || 'Player 1').capitalize]
  end

  def set_second_name(vs_ai, names)
    if vs_ai
      names << '_computer'
      puts 'Do you want to guess first in game 1?'
      /[yY]/.match? gets ? names.reverse! : names
    else
      puts "What's player 2's name?"
      names << (gets.strip || 'Player 2').capitalize
    end
  end

  def midgame?(midgame_data)
    @midgame = !midgame_data.empty?
  end

  def hash_of_game_data
    Hash[instance_variables.map { |name| [name, instance_variable_get(name)] }]
  end

  def continue_to_next_game?
    @series.p
    puts 'Rematch, save or exit?'
    case gets
    when /[eE]/
      nil
    when /[sS]/
      @series.save_game
    else
      @id_of_leader ^= 1
      @midgame = false
      return true
    end
    false
  end
end
