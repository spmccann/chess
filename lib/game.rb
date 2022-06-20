# frozen_string_literal: true

require_relative 'board'
require_relative 'pieces'
require_relative 'messages'

messages = Messages.new
board = Board.new

messages.welcome
messages.names
messages.greeting
messages.move

board.create_board_squares

board.set_position
board.draw_board
puts board.chessboard
