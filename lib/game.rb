# frozen_string_literal: true

require_relative 'board'
require_relative 'messages'
require_relative 'notation'
require_relative 'moves'
require_relative 'serialize'

game_loop = true
turn = true

notation = Notation.new
notation.numbers_to_algebraic
notation.create_board_coordinates

moves = Moves.new
board = Board.new(moves.new_board)

messages = Messages.new
messages.welcome
messages.names_request

serialize = Serialize.new(moves.new_board, messages.names, turn)
messages.greeting
board.display_board

while game_loop
  # inform the player it's their turn ask for a move
  messages.your_move(turn)
  player_move = messages.ask_move
  # Options (save, load, new game, quit)
  if %w[S R L Q H].include?(player_move)
    serialize.option_selector(player_move)
    messages.confirmation(player_move)
    case player_move
    when 'L'
      messages.names(serialize.names[0], serialize.names[1])
      board = Board.new(serialize.game)
      turn = serialize.turn
      board.display_board
    when 'R'
      board = Board.new(moves.reset_board)
      board.display_board
      turn = true
    when 'Q'
      game_loop = false
    end
  # proceed with the move if player input has the correct notation
  elsif notation.notation_valid_format(player_move)
    notation.submit_move(player_move)
    # checks that moves follow game rules
    if moves.basic_move_rules(notation.input_start, notation.input_end,
                              turn) && moves.piece_specific_rules(notation.cords_start, notation.cords_end,
                                                                  notation.input_start)
      moves.make_moves(notation.input_start, notation.input_end)
      board = Board.new(moves.new_board)
      system 'clear'
      messages.next_turn
      board.display_board
      turn = !turn
    else
      messages.invalid_chess_move
    end
  else
    messages.invalid_notation
  end
end
