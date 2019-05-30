# Generic series of games of one type against ai or between 2 players
class Series
  def initialize(vs_ai, names, options, record = [])
    @vs_ai = vs_ai
    @names = names
    options.each { |key, val| instance_variable_set("@#{key}", val) }
    @record = record
  end

  def new_game(id_of_leader, midgame_data = {})
    @game = if @vs_ai
              if @names[id_of_leader] == '_computer'
                AILead.new(midgame_data)
              else AIFollow.new(midgame_data)
              end
            else PvP.new(midgame_data)
            end
  end

  def p(p1_ws, p2_ws)
    puts "#{@names[0]} - #{p1_ws}; #{@names[1]} - #{p2_ws}."
  end

  def save_game(midgame_data = {})
    require 'json'
    saved = File.exist?('saved.json') ? JSON.parse(File.read('saved.json')) : {}
    series_name = choose_series_name(saved)
    saved[series_name] = save_hash(game_num, midgame_data)
    File.write('saved.json', saved.to_json)
    'saved'
  end

  private

  def choose_series_name(saved)
    puts 'What do you want to call this game?'
    series_name = gets.strip
    return series_name unless saved[series_name]

    puts 'A game is already saved with that name. Overwrite it?'
    gets =~ /[yY]/ ? series_name : choose_series_name(saved)
  end

  def save_hash(midgame_data)
    h = { game: self.class.name, midgame_data: midgame_data, options: {} }
    instance_variables.each do |var|
      if %w[@vs_ai @names @record].include?(var)
        h[de_instantize(var)] = instance_variable_get(var)
      else
        h[:options][de_instantize(var)] = instance_variable_get(var)
      end
    end
  end

  def de_instantize(var)
    var[1..-1].to_sym
  end
end
