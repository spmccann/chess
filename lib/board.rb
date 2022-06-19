# frozen_string_literal: true

require 'colorize'

# chessboard
class Board
  attr_accessor(:board, :chessboard)

  def initialize
    @ranks = [*0..7]
    @files = [*0..7]
    @board = []
    @chessboard = ''
  end

  def create_board_squares
    i = 0
    while i < 8
      @board += @ranks.map { |r| [@files[r], i] }
      i += 1
    end
  end

  def draw_board
    alt = true
    @board.each_index do |file|
      if (file % 8).zero? && file.positive?
        @chessboard += "\n"
        alt = !alt
      end
      if alt
        @chessboard += ' ♜ '.colorize(:white).on_light_green
        alt = false
      else
        @chessboard += ' ♜ '.colorize(:black).on_white
        alt = true
      end
    end
  end
end
