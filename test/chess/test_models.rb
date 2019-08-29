require 'minitest/autorun'

class SaveDataSwitcher
  def initialize
    base_path = '../../lib/'
    old = base_path + 'saved.json'
    @save_data = if File.exist? old
                   SaveData.new(old, base_path + '.saved.json')
                 else NoSaveData
                 end
  end

  def switch
    @save_data.switch
  end
end

class SaveData
  def initialize(old, temp)
    @old = old
    @temp = temp
    @switched = false
  end

  def switch
    @switched ? File.rename(@temp, @old) : File.rename(@old, @temp)
    @switched = !@switched
  end
end

class NoSaveData
  def self.switch; end
end

# Controller
class ControllerNoLoadTest < Minitest::Test
  %w[../../lib/controller_root.rb ../../lib/controller_turn_based.rb
     ../../lib/chess/controller.rb].each { |file| require_relative file }
  def setup
    @save_data_paths = SaveDataSwitcher.new
    @save_data_paths.switch
  end

  def teardown
    @save_data_paths.switch
  end

  def test_doesnt_offer_load; end
end

# Series
class EmptySeriesTest < Minitest::Test
  %w[../../lib/series_root.rb ../../lib/series_turn_based.rb
     ../../lib/chess/series.rb].each { |file| require_relative file }

  def setup
    @series = ChessSeries.new
  end
end

# Game
class GameTest < Minitest::Test
  require_relative 'lib/chess/game.rb'
  def setup; end
end

# Board
class BoardTest < Minitest::Test; end

# Graveyard
class GraveyardTest < Minitest::Test; end

# Record
class RecordTest < Minitest::Test; end

# MoveMaker
class MoveMakerTest < Minitest::Test; end

# Move
class MoveTest < Minitest::Test; end

# MoveAlgebra
class MoveAlgebraTest < Minitest::Test; end
