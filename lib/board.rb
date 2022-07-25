# frozen_string_literal: true

require 'colorize'

# chessboard
class Board
  attr_accessor(:chessboard)

  def initialize(input_board = Array.new(81, '  '))
    @chessboard = []
    @input_board = input_board
  end

  def draw_board
    alt = true
    @input_board.each_with_index do |square, i|
      if (i % 9).zero? && i.positive?
        @chessboard << "\n"
        alt = !alt
      end
      if i > 71 || (i % 9).zero?
        @chessboard << " #{square} ".white.on_black
      elsif alt
        @chessboard << " #{square} ".on_light_yellow
        alt = false
      else
        @chessboard << " #{square} ".on_light_cyan
        alt = true
      end
    end
  end

  def display_board
    draw_board
    puts @chessboard.join
  end
end
