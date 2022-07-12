# frozen_string_literal: true

require_relative 'pieces'
require_relative 'notation'
require_relative 'cords_module'

# accepts player inputs to update the board and pieces positions
class Moves
  attr_accessor(:new_board, :test_board, :castle_rights)

  include Coordinates

  def initialize
    @piece = Pieces.new
    @castle_rights = [0, 0, 0, 0]
    @new_board =
      ['8', @piece.black[2], @piece.black[4], @piece.black[3], @piece.black[1], @piece.black[0], @piece.black[3], @piece.black[4], @piece.black[2],
       '7', @piece.black[5], @piece.black[5], @piece.black[5], @piece.black[5], @piece.black[5], @piece.black[5], @piece.black[5], @piece.black[5],
       '6', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
       '5', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
       '4', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
       '3', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
       '2', @piece.white[5], @piece.white[5], @piece.white[5], @piece.white[5], @piece.white[5], @piece.white[5], @piece.white[5], @piece.white[5],
       '1', @piece.white[2], @piece.white[4], @piece.white[3], @piece.white[1], @piece.white[0], @piece.white[3], @piece.white[4], @piece.white[2],
       ' ', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H']
  end

  # def helper_board_square_numbers
  #   positions = [*0..80]
  #   positions.map! { |f| format('%02d', f) }
  # end

  # update the board
  def make_moves(start_square, end_square)
    @new_board[end_square] = @new_board[start_square]
    @new_board[start_square] = ' '
  end

  def test_moves(start_square, end_square)
    @test_board = @new_board.dup
    @test_board[end_square] = @test_board[start_square]
    @test_board[start_square] = ' '
  end

  # general rules for movement
  def basic_move_rules(start_square, end_square, turn)
    start_piece_exists(start_square) && end_piece_not_same_color(end_square,
                                                                 turn) && turn_color_match(start_square, turn)
  end

  def start_piece_exists(start_square)
    @new_board[start_square] != ' '
  end

  def end_piece_not_same_color(end_square, turn)
    turn ? !@piece.white.include?(@new_board[end_square]) : !@piece.black.include?(@new_board[end_square])
  end

  def turn_color_match(start_square, turn)
    turn ? @piece.white.include?(@new_board[start_square]) : @piece.black.include?(@new_board[start_square])
  end

  # piece specific move rules
  def piece_picker(start_cord, end_cord, start_square, board)
    case @new_board[start_square]
    when @piece.white[0], @piece.black[0]
      king(start_cord, end_cord)
    when @piece.white[1], @piece.black[1]
      queen(start_cord, end_cord, board)
    when @piece.white[2], @piece.black[2]
      rook(start_cord, end_cord, board)
    when @piece.white[3], @piece.black[3]
      bishop(start_cord, end_cord, board)
    when @piece.white[4], @piece.black[4]
      knight(start_cord, end_cord)
    when @piece.white[5], @piece.black[5]
      pawn(start_cord, end_cord, start_square)
    end
  end

  # checks if any pieces are way of requested move
  def clear_path?(board)
    notation = Notation.new
    @path.each { |c| return false if board[notation.number_from_cord(c)] != ' ' }
  end

  def king(start_cord, end_cord)
    KING_CORDS.include?([start_cord[0] - end_cord[0], start_cord[1] - end_cord[1]])
  end

  def queen(start_cord, end_cord, board)
    rook(start_cord, end_cord, board) || bishop(start_cord, end_cord, board)
  end

  def rook(start_cord, end_cord, board)
    return unless (start_cord[0] - end_cord[0]).zero? || (start_cord[1] - end_cord[1]).zero?

    rook_path(start_cord, end_cord)
    clear_path?(board)
  end

  def rook_path(start_cord, end_cord)
    @path = []
    i = 1
    diff = [(end_cord[0] - start_cord[0]).abs, (end_cord[1] - start_cord[1]).abs]
    while i < diff.max
      @path << if diff[0].positive? && start_cord[0] < end_cord[0]
                 [start_cord[0] + i, start_cord[1]]
               elsif diff[0].positive? && start_cord[0] > end_cord[0]
                 [start_cord[0] - i, start_cord[1]]
               elsif diff[1].positive? && start_cord[1] < end_cord[1]
                 [start_cord[0], start_cord[1] + i]
               else
                 [start_cord[0], start_cord[1] - i]
               end
      i += 1
    end
  end

  def bishop(start_cord, end_cord, board)
    return unless (end_cord[0] - start_cord[0]).abs == (end_cord[1] - start_cord[1]).abs

    bishop_path(start_cord, end_cord)
    clear_path?(board)
  end

  def bishop_path(start_cord, end_cord)
    @path = []
    n = 1
    distance = (end_cord[0] - start_cord[0]).abs
    while n < distance
      @path << if start_cord[0] < end_cord[0] && start_cord[1] < end_cord[1]
                 [start_cord[0] + n, start_cord[1] + n]
               elsif start_cord[0] < end_cord[0] && start_cord[1] > end_cord[1]
                 [start_cord[0] + n, start_cord[1] - n]
               elsif start_cord[0] > end_cord[0] && start_cord[1] < end_cord[1]
                 [start_cord[0] - n, start_cord[1] + n]
               else
                 [start_cord[0] - n, start_cord[1] - n]
               end
      n += 1
    end
  end

  def knight(start_cord, end_cord)
    KNIGHT_CORDS.include?([start_cord[0] - end_cord[0], start_cord[1] - end_cord[1]])
  end

  def pawn(start_cord, end_cord, start_square)
    if @new_board[start_square] == @piece.white[5]
      cords = PAWN_WHITE_CORDS
      start_num = 6
      mid_cord = [end_cord[0], end_cord[1] + 1]
    else
      cords = PAWN_BLACK_CORDS
      start_num = 1
      mid_cord = [end_cord[0], end_cord[1] - 1]
    end
    pawn_moves(cords, start_num, start_cord, end_cord, mid_cord)
  end

  def pawn_moves(cords, start_num, start_cord, end_cord, mid_cord)
    pawn_test = [start_cord[0] - end_cord[0], start_cord[1] - end_cord[1]]
    diag_capture = cords[2..3].include?(pawn_test)
    return true if start_cord[1] == start_num && cords[1] == pawn_test && !pawn_capture(end_cord) && pawn_mid(mid_cord)
    return true if cords[0] == pawn_test && !pawn_capture(end_cord) || (diag_capture && pawn_capture(end_cord))
  end

  # true if diag capture and using the negation if moving ahead
  def pawn_capture(end_cord)
    notation = Notation.new
    @new_board[notation.number_from_cord(end_cord)] != ' '
  end

  # checking that there's no piece one square ahead if moving 2 squares
  def pawn_mid(mid_cord)
    notation = Notation.new
    @new_board[notation.number_from_cord(mid_cord)] == ' '
  end

  # castling
  def castle(player_move, turn)
    select_castle(player_move, turn)
    if valid_castle && castling_rights(player_move, turn)
      castle_move
    else
      false
    end
  end

  def select_castle(player_move, turn)
    @moveset = if player_move == '0-0' && turn
                 CASTLE_SHORT_WHITE
               elsif player_move == '0-0' && !turn
                 CASTLE_SHORT_BLACK
               elsif player_move == '0-0-0' && turn
                 CASTLE_LONG_WHITE
               else
                 CASTLE_LONG_BLACK
               end
  end

  def valid_castle
    if @moveset.length == 4
      @new_board[@moveset[0]] == ' ' && new_board[@moveset[2]] == ' '
    else
      @new_board[@moveset[0]] == ' ' && new_board[@moveset[2]] == ' ' && new_board[@moveset[4]] == ' '
    end
  end

  def move_counter
    if @new_board[CASTLE_SHORT_WHITE[1]] != @piece.white[0] || @new_board[CASTLE_SHORT_WHITE[3]] != @piece.white[2]
      @castle_rights[0] += 1
    end
    if @new_board[CASTLE_LONG_WHITE[1]] != @piece.white[0] || @new_board[CASTLE_LONG_WHITE[3]] != @piece.white[2]
      @castle_rights[1] += 1
    end
    if @new_board[CASTLE_SHORT_BLACK[1]] != @piece.black[0] || @new_board[CASTLE_SHORT_BLACK[3]] != @piece.black[2]
      @castle_rights[2] += 1
    end
    if @new_board[CASTLE_LONG_BLACK[1]] != @piece.black[0] || @new_board[CASTLE_LONG_BLACK[3]] != @piece.black[2]
      @castle_rights[3] += 1
    end
  end

  def castling_rights(player_move, turn)
    if player_move == '0-0' && turn
      @castle_rights[0].zero?
    elsif player_move == '0-0-0' && turn
      @castle_rights[1].zero?
    elsif player_move == '0-0' && !turn
      @castle_rights[2].zero?
    else
      @castle_rights[3].zero?
    end
  end

  def castle_move
    @new_board[@moveset[0]] = @new_board[@moveset[1]]
    @new_board[@moveset[1]] = ' '
    @new_board[@moveset[2]] = @new_board[@moveset[3]]
    @new_board[@moveset[3]] = ' '
  end

  # checking
  def king_checks(board)
    return true if knight_check(king_coordinates(board), board) == 'check'
    return true if bishop_check(king_coordinates(board), board) == 'check'
    return true if rook_check(king_coordinates(board), board) == 'check'
    return true if queen_check(king_coordinates(board), board) == 'check'

    false
  end

  def king_coordinates(board)
    notation = Notation.new
    notation.cord_from_number(board.index(@king_color[0]))
  end

  def piece_color(turn)
    @attack_color = turn ? @piece.black : @piece.white
    @king_color = turn ? @piece.white : @piece.black
  end

  # create an array of cords of the requested piece type
  def find_all_piece_by_type(num, board)
    notation = Notation.new
    @all_pieces = []
    board.each_with_index { |p, i| @all_pieces << notation.cord_from_number(i) if p == @attack_color[num] }
  end

  def queen_check(king_cord, board)
    find_all_piece_by_type(1, board)
    @all_pieces.each { |q| return 'check' if queen(q, king_cord, board) }
  end

  def rook_check(king_cord, board)
    find_all_piece_by_type(2, board)
    @all_pieces.each { |r| return 'check' if rook(r, king_cord, board) }
  end

  def bishop_check(king_cord, board)
    find_all_piece_by_type(3, board)
    @all_pieces.each { |b| return 'check' if bishop(b, king_cord, board) }
  end

  def knight_check(king_cord, board)
    find_all_piece_by_type(4, board)
    @all_pieces.each { |n| return 'check' if knight(n, king_cord) }
  end

  # def pawn_check(king_cord, board)
  #   find_all_piece_by_type(5, board)
  #   @all_pieces.each { |n| return 'check' if pawn(n, king_cord) }
  # end

  # new game
  def resigns
    ['8', @piece.black[2], @piece.black[4], @piece.black[3], @piece.black[1], @piece.black[0], @piece.black[3], @piece.black[4], @piece.black[2],
     '7', @piece.black[5], @piece.black[5], @piece.black[5], @piece.black[5], @piece.black[5], @piece.black[5], @piece.black[5], @piece.black[5],
     '6', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
     '5', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
     '4', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
     '3', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
     '2', @piece.white[5], @piece.white[5], @piece.white[5], @piece.white[5], @piece.white[5], @piece.white[5], @piece.white[5], @piece.white[5],
     '1', @piece.white[2], @piece.white[4], @piece.white[3], @piece.white[1], @piece.white[0], @piece.white[3], @piece.white[4], @piece.white[2],
     ' ', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H']
  end
end
