# frozen_string_literal: true

require_relative 'board'
require_relative 'pieces'
require_relative 'messages'
require_relative 'notation'
require_relative 'moves'

messages = Messages.new
notation = Notation.new
moves = Moves.new
board = Board.new(moves.new_game)

notation.numbers_to_algebraic
notation.create_board_coordinates

# messages.welcome
messages.names
# messages.greeting

game_loop = true
turn = true
board.display_board

while game_loop
  messages.move(turn)
  if notation.collect_move && moves.basic_move_rules(notation.input_start, notation.input_end, turn)
    moves.game_in_progress(notation.input_start, notation.input_end)
    board = Board.new(moves.new_game)
    system 'clear'
    messages.next_turn
    board.display_board
    turn = !turn
  else
    messages.invalid_move
  end
end
