# frozen_string_literal: true

require 'colorize'
require_relative 'pieces'

# chessboard
class Board
  attr_accessor(:board, :chessboard)

  def initialize
    @ranks = [*0..7]
    @files = [*0..7]
    @board = []
    @chessboard = ''
    @positions = Array.new(64, '')
    @p = Pieces.new
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
    @board.each_index do |i|
      if (i % 8).zero? && i.positive?
        @chessboard += "\n"
        alt = !alt
      end
      if alt
        @chessboard += " #{@positions[i]} ".on_light_white
        alt = false
      else
        @chessboard += " #{@positions[i]} ".on_light_green
        alt = true
      end
    end
  end

  def set_position
    starting_postion
  end

  def square_numbers
    @positions = [*0..63]
    @positions.map! { |f| format('%02d', f) }
  end

  def square_coordinates
    @positions = @board
  end

  def starting_postion
    @positions = [@p.black[2], @p.black[4], @p.black[3], @p.black[1], @p.black[0], @p.black[3], @p.black[4], @p.black[2],
                  @p.black[5], @p.black[5], @p.black[5], @p.black[5], @p.black[5], @p.black[5], @p.black[5], @p.black[5],
                  ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
                  ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
                  ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
                  ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
                  @p.white[5], @p.white[5], @p.white[5], @p.white[5], @p.white[5], @p.white[5], @p.white[5], @p.white[5],
                  @p.white[2], @p.white[4], @p.white[3], @p.white[1], @p.white[0], @p.white[3], @p.white[4], @p.white[2]]
  end

  def make_move
    @positions[28] = @p.black[5]
    @positions[12] = ' '
  end
end
