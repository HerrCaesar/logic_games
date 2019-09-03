# Contains classes that read from and write to stdin & stdout, and local files
module CommandLine
  # Retrieves saved series
  class SavedGameRetriever
    attr_reader :saved
    def initialize(game_type, file = 'saved.json')
      @file = file
      @game_type = game_type
      @saved = nil
    end

    def prepare_series_options
      return self unless File.exist?(@file)

      require 'json'
      @saved = JSON.parse(File.read(@file)).select do |_key, saved_game|
        saved_game['game_type'] == game_type
      end.sort.to_h
      self
    end

    def any?
      saved.any?
    end
  end

  # Requests and gets user input from the command line
  class UserInterface
    def self.send(message: '', options:)
      UserInterface.add_enter_as_null_option(options)
      puts message
      options.each { |number, option| puts "(#{number}) #{option}" }
    end

    def self.add_enter_as_null_option(options)
      options[''] = 'Or press enter to ' + options[''].downcase
    end

    # Originally in controller
    def give_and_get
      until series_data
        ins = gets.chomp
        break if ins.empty?
  
        parse_input(ins)
      end
    end

    private

    def parse_input(ins)
      @series_data =
        if /^\d+$/.match?(ins) && (key = saved.keys[ins.to_i - 1])
          saved[key]
        else saved[ins]
        end
    end
  end
end
