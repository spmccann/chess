# frozen_string_literal: true

require_relative 'pieces'

# Keeps track of the current board
class Position
  attr_accessor(:new_board)

  def initialize
    @piece = Pieces.new
    @new_board =
      ['8', @piece.black[2], @piece.black[4], @piece.black[3], @piece.black[1], @piece.black[0], @piece.black[3], @piece.black[4], @piece.black[2],
       '7', @piece.black[5], @piece.black[5], @piece.black[5], @piece.black[5], @piece.black[5], @piece.black[5], @piece.black[5], @piece.black[5],
       '6', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
       '5', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
       '4', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
       '3', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
       '2', @piece.white[5], @piece.white[5], @piece.white[5], @piece.white[5], @piece.white[5], @piece.white[5], @piece.white[5], @piece.white[5],
       '1', @piece.white[2], @piece.white[4], @piece.white[3], @piece.white[1], @piece.white[0], @piece.white[3], @piece.white[4], @piece.white[2],
       ' ', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H']
  end
end
