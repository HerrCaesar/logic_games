# Constructs a Series, injecting it with data loaded from save file, or options
# selected by the user
class SeriesInitializer
  attr_reader :series
  def initialize(series_class)
    @series = series_class.new
    @series = set_series_options
  end

  private

  def set_series_options
    retriever = SavedGameRetriever.new(series_class)
    return Series.set_options unless
      retriever.file_saved? && retriever.parse_saved_series.any? &&
      (selector = SavedGameSelector.new(retriever.saved))
      .offer_load
      .series_selected?

    series.load(selector.series_data)
  end
end

# Retrieves saved series
class SavedGameRetriever
  attr_reader :saved
  def initialize(series_class)
    @file = 'saved.json'
    @series_class = series_class
  end

  def file_saved?
    File.exist?(@file)
  end

  def parse_saved_series
    require 'json'
    @saved = JSON.parse(File.read(@file)).select do |_key, series_class|
      series_class['game'] == @series_class
    end.sort.to_h
    self
  end

  def any?
    @saved.any?
  end
end

# Selects saved series
class SavedGameSelector
  attr_reader :series_data
  def initialize(save_hash)
    @save_hash = save_hash
  end

  def offer_load
    display_saved_files
    puts 'Select a game to load. Or press enter to create a new game.'
    until series_data
      ins = gets.chomp
      break if ins.empty?

      parse_input(ins)
    end
    self
  end

  def series_selected?
    !series_data.nil?
  end

  private

  def display_saved_files
    saved.each_with_index { |(key, _val), index| puts "(#{index + 1}) #{key}" }
  end

  def parse_input(ins)
    @series_data =
      if /^\d+$/.match?(ins) && (key = saved.keys[ins.to_i - 1])
        saved[key]
      else saved[ins]
      end
  end
end
