# frozen_string_literal: true

require 'json'

# save, load, delete game data
class Serialize
  def initialize(game)
    @game = game
  end

  def save_game
    Dir.mkdir('saves') unless Dir.exist?('saves')
    save_file = 'saves/game.txt'
    File.open(save_file, 'w') { |f| f.puts @game.to_s }
  end
end
