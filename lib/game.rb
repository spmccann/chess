# frozen_string_literal: true

require_relative 'board'
require_relative 'pieces'
require_relative 'messages'
require_relative 'notation'
require_relative 'moves'

# messages = Messages.new

notation = Notation.new
moves = Moves.new
board = Board.new(moves.helper_board_square_numbers)

notation.numbers_to_algebraic
notation.create_board_coordinates
notation.numbers_to_coordinates

# messages.welcome
board.draw_board
# messages.names
# messages.greeting
# messages.move
board.display_board
