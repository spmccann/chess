# frozen_string_literal: true

require_relative 'board'
require_relative 'pieces'

# accepts player inputs to update the board and pieces
class Moves
  def initialize
    @p = Pieces.new
  end

  def helper_board_square_numbers
    positions = [*0..80]
    positions.map! { |f| format('%02d', f) }
  end

  def new_game
    ['8', @p.black[2], @p.black[4], @p.black[3], @p.black[1], @p.black[0], @p.black[3], @p.black[4], @p.black[2],
     '7', @p.black[5], @p.black[5], @p.black[5], @p.black[5], @p.black[5], @p.black[5], @p.black[5], @p.black[5],
     '5', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
     '5', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
     '4', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
     '3', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
     '2', @p.white[5], @p.white[5], @p.white[5], @p.white[5], @p.white[5], @p.white[5], @p.white[5], @p.white[5],
     '1', @p.white[2], @p.white[4], @p.white[3], @p.white[1], @p.white[0], @p.white[3], @p.white[4], @p.white[2],
     ' ', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H']
  end
end
