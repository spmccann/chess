# frozen_string_literal: true
require_relative 'board'
require_relative 'pieces'

board = Board.new
board.create_board_squares
board.draw_board
puts board.chessboard
