# frozen_string_literal: true

require 'json'

# save, load, delete game data
class Serialize
  attr_accessor(:game, :names, :turn)

  def initialize(game, names, turn)
    @game = game
    @names = names
    @turn = turn
  end

  def save_game
    data = @game, @names, @turn
    Dir.mkdir('saves') unless Dir.exist?('saves')
    save_file = 'saves/game.txt'
    File.open(save_file, 'w') { |f| f.puts data.to_s }
  end

  def load_game
    if Dir.exist?('saves')
      user_load = File.open('saves/game.txt', 'r').readline
      saves = JSON.parse(user_load)
      @game = saves[0]
      @names = saves[1]
      @turn = saves[2]
    else
      puts 'No saves found!'
    end
  end

  def option_selector(choice)
    case choice
    when 'S'
      save_game
    when 'L'
      load_game
    end
  end
end
