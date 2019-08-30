# Constructs a Series, injecting dependencies passed from game modules, as well
# as data loaded from save file, or options selected by the user
class SeriesInitializer
  attr_reader :series
  def self.create_series(game_type, saved_game_retriever = SavedGameRetriever)
    @series = game_type.new
    series_options(saved_game_retriever)
  end

  private

  def series_options(saved_game_retriever)
    retriever = saved_game_retriever.new(game_type)
    # return series.set_options unless
    series_data =
      retriever.prepare_series_options.any? &&
      SavedGameSelector.new(retriever.saved).offer_load

    series.send(*series_data)
    # series.load(selector.series_data)
  end
end

# Selects saved series
class SavedGameSelector
  attr_reader :series_data
  def initialize(save_hash)
    @save_hash = save_hash
  end

  # Offer save files (/cancel) to client. It displays & interprets response.
  def offer_load
    {
      message: 'Select a game to load',
      options: saved_file_options.merge('' => 'Create a new game')
    }
  end

  def series_selected?
    !series_data.nil?
  end

  private

  def saved_file_options
    saved.map.with_index { |(key, _val), index| [(index + 1).to_s, key] }.to_h
  end
end
