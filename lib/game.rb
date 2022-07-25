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

messages = Messages.new
messages.welcome
messages.names_request

serialize = Serialize.new(moves.new_board, messages.names, turn, moves.castle_rights)

while game_loop
  # inform the player it's their turn and ask for a move
  serialize.turn = turn
  messages.next_turn
  board = Board.new(moves.new_board)
  board.display_board
  moves.piece_color(turn)
  moves.move_counter
  if moves.piece_access(moves.king_coordinates(moves.new_board), moves.new_board)
    if moves.checkmate(turn, moves.new_board)
      messages.checkmate(turn)
      messages.new_game? ? moves.reset_game : break
      board = Board.new(moves.new_board)
      board.display_board
      turn = true
    else
      messages.check(turn)
    end
  end
  messages.your_move(turn)
  player_move = messages.ask_move
  # Options (save, load, new game, quit)
  if %w[S L Q H].include?(player_move)
    serialize.option_selector(player_move)
    messages.confirmation(player_move)
    case player_move
    when 'L'
      system 'clear'
      messages.names(serialize.names[0], serialize.names[1])
      moves.new_board = serialize.game
      board = Board.new(serialize.game)
      turn = serialize.turn
      moves.castle_rights = serialize.castle_rights
    when 'Q'
      game_loop = false
    end
  # castling
  elsif %w[0-0 0-0-0].include?(player_move)
    system 'clear'
    if moves.castle(player_move, turn)
      turn = !turn
    else
      messages.invalid_castle
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
      moves.checkers = []
      if moves.piece_access(moves.king_coordinates(moves.test_board), moves.test_board)
        system 'clear'
        next
      end
      # make the move on the board
      moves.make_moves(notation.input_start, notation.input_end)
      moves.promotion?(turn)
      turn = !turn
      system 'clear'
    else
      system 'clear'
      messages.invalid_chess_move
    end
  else
    system 'clear'
    messages.invalid_notation
  end
end
