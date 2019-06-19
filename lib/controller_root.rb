require_relative 'cntrlr_models.rb'

# General formula for running a series of games
class Controller
  def do_a_round
    setup_round unless @midgame
    play_round
  end

  private

  def setup(s_class, options = nil, offer_load = true)
    saved = saved_games_available(s_class.name)
    if saved.any? && offer_load && load_series?
      old_game = pick_game(saved)
      return setup(s_class, options, false) unless old_game

      load_existing_series(s_class, old_game)
    else create_series(s_class)
    end
  end

  def saved_games_available(s_class)
    return false unless File.exist?('saved.json')

    require 'json'
    JSON.parse(File.read('saved.json')).select do |_k, gameclass|
      gameclass['game'] == s_class
    end.sort.to_h
  end

  def load_series?
    print 'Start new game or load from file?  '
    gets =~ /[LlFf]/
  end

  def pick_game(saved)
    puts 'Which game do you want to load? (or just press enter to cancel)'
    display_save_files(saved)
    ins = gets.chomp
    return false if ins.empty?

    if /^\d+$/.match? ins
      saved[saved.keys[ins.to_i - 1]] || pick_game(saved)
    else saved[ins] || pick_game(saved)
    end
  end

  def display_save_files(saved)
    saved.each_with_index { |(key, _val), index| puts "(#{index + 1}) #{key}" }
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
    @vs_ai = vs_ai?
    names = Names.new(@vs_ai)
    @id_of_leader = 0
    names.choose_second(@vs_ai)
    @series = s_class.new(@vs_ai, names, options)
  end

  def vs_ai?
    print '1-player (1) or 2-player (2)?  '
    !/2/.match?(gets)
  end

  def hash_of_game_data
    Hash[instance_variables.map { |name| [name, instance_variable_get(name)] }]
  end

  def stop_playing?
    @series.p
    case gets
    when /[eE]/
      true
    when /[sS]/
      @series.save_game
    else
      @id_of_leader ^= 1
      @midgame = false
    end
  end
end
