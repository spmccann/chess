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

moves = Moves.new
board = Board.new(moves.new_board)

messages = Messages.new
messages.welcome
messages.names_request

serialize = Serialize.new(moves.new_board, messages.names, turn)
messages.greeting

while game_loop
  # inform the player it's their turn ask for a move
  system 'clear'
  messages.next_turn
  board.display_board
  moves.piece_color(turn)
  messages.check(turn) if moves.king_checks(moves.new_board)
  messages.your_move(turn)
  player_move = messages.ask_move
  # Options (save, load, new game, quit)
  if %w[S R L Q H].include?(player_move)
    serialize.option_selector(player_move)
    messages.confirmation(player_move)
    case player_move
    when 'L'
      system 'clear'
      messages.names(serialize.names[0], serialize.names[1])
      moves.new_board = serialize.game
      board = Board.new(serialize.game)
      turn = serialize.turn
      messages.next_turn
    when 'R'
      board = Board.new(moves.resigns)
      turn = true
    when 'Q'
      game_loop = false
    end
  # proceed with the move if player input has the correct notation
  elsif notation.notation_valid_format(player_move)
    notation.submit_move(player_move)
    # checks that moves follow game rules
    if moves.basic_move_rules(notation.input_start, notation.input_end,
                              turn) && moves.piece_picker(notation.cords_start, notation.cords_end,
                                                          notation.input_start, moves.new_board)
      # verifies a player in check makes a move out and also not in
      moves.test_moves(notation.input_start, notation.input_end)
      next if moves.king_checks(moves.test_board)
      
      # make the move on the board
      moves.make_moves(notation.input_start, notation.input_end)
      board = Board.new(moves.new_board)
      turn = !turn
    else
      messages.invalid_chess_move
    end
  else
    messages.invalid_notation
  end
end
