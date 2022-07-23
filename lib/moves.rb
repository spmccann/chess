# frozen_string_literal: true

require_relative 'pieces'
require_relative 'notation'
require_relative 'cords_module'

# accepts player inputs to update the board and pieces positions
class Moves
  attr_accessor(:new_board, :test_board, :castle_rights, :checkers)

  include Coordinates

  def initialize
    @piece = Pieces.new
    @notation = Notation.new
    @castle_rights = [0, 0, 0, 0]
    @checkers = []
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
      king(start_cord, end_cord, board)
    when @piece.white[1], @piece.black[1]
      queen(start_cord, end_cord, board)
    when @piece.white[2], @piece.black[2]
      rook(start_cord, end_cord, board)
    when @piece.white[3], @piece.black[3]
      bishop(start_cord, end_cord, board)
    when @piece.white[4], @piece.black[4]
      knight(start_cord, end_cord)
    when @piece.white[5], @piece.black[5]
      pawn(start_cord, end_cord, board)
    end
  end

  # checks if any pieces are way of move
  def clear_path?(board)
    @path.each { |c| return false if board[@notation.number_from_cord(c)] != ' ' }
  end

  def king(start_cord, end_cord, board)
    KING_CORDS.include?([start_cord[0] - end_cord[0], start_cord[1] - end_cord[1]]) unless no_king_check(board,
                                                                                                         end_cord)
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

  # using board in a useless way as a placeholder
  def knight(start_cord, end_cord)
    KNIGHT_CORDS.include?([start_cord[0] - end_cord[0], start_cord[1] - end_cord[1]])
  end

  def pawn(start_cord, end_cord, board)
    if board[@notation.number_from_cord(start_cord)] == @piece.white[5]
      cords = PAWN_WHITE_CORDS
      start_num = 6
      mid_cord = [end_cord[0], end_cord[1] + 1]
    else
      cords = PAWN_BLACK_CORDS
      start_num = 1
      mid_cord = [end_cord[0], end_cord[1] - 1]
    end
    pawn_moves(cords, start_num, start_cord, end_cord, mid_cord, board)
  end

  def pawn_moves(cords, start_num, start_cord, end_cord, mid_cord, board)
    pawn_test = [start_cord[0] - end_cord[0], start_cord[1] - end_cord[1]]
    diag_capture = cords[2..3].include?(pawn_test)
    return true if start_cord[1] == start_num && cords[1] == pawn_test && !pawn_capture(end_cord,
                                                                                        board) && pawn_mid(mid_cord,
                                                                                                           board)
    return true if cords[0] == pawn_test && !pawn_capture(end_cord,
                                                          board) || (diag_capture && pawn_capture(end_cord, board))
  end

  # true if diag capture and using the negation if moving ahead
  def pawn_capture(end_cord, board)
    board[@notation.number_from_cord(end_cord)] != ' '
  end

  # checking that there's no piece one square ahead if moving 2 squares
  def pawn_mid(mid_cord, board)
    board[@notation.number_from_cord(mid_cord)] == ' '
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
      @new_board[@moveset[0]] == ' ' && @new_board[@moveset[2]] == ' '
    else
      @new_board[@moveset[0]] == ' ' && @new_board[@moveset[2]] == ' ' && @new_board[@moveset[4]] == ' '
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

  # checks
  def piece_access(end_cord, board, side = @opp_pieces)
    knight_access(end_cord, board, side)
    bishop_access(end_cord, board, side)
    rook_access(end_cord, board, side)
    queen_access(end_cord, board, side)
    pawn_access(end_cord, board, side)
    return true unless @checkers.empty?

    false
  end

  def king_coordinates(board)
    @notation.cord_from_number(board.index(@own_pieces[0]))
  end

  def piece_color(turn)
    @opp_pieces = turn ? @piece.black : @piece.white
    @own_pieces = turn ? @piece.white : @piece.black
  end

  def find_all_piece_by_type(num, board, side)
    @all_pieces = []
    board.each_with_index { |p, i| @all_pieces << @notation.cord_from_number(i) if p == side[num] }
  end

  def queen_access(end_cord, board, side)
    find_all_piece_by_type(1, board, side)
    @all_pieces.each { |q| @checkers << q if queen(q, end_cord, board) }
  end

  def rook_access(end_cord, board, side)
    find_all_piece_by_type(2, board, side)
    @all_pieces.each { |r| @checkers << r if rook(r, end_cord, board) }
  end

  def bishop_access(end_cord, board, side)
    find_all_piece_by_type(3, board, side)
    @all_pieces.each { |b| @checkers << b if bishop(b, end_cord, board) }
  end

  def knight_access(end_cord, board, side)
    find_all_piece_by_type(4, board, side)
    @all_pieces.each { |n| @checkers << n if knight(n, end_cord) }
  end

  def pawn_access(end_cord, board, side)
    find_all_piece_by_type(5, board, side)
    @all_pieces.each { |p| @checkers << p if pawn(p, end_cord, board) }
  end

  def no_king_check(board, end_cord)
    current_king = @notation.cord_from_number(board.index(@opp_pieces[0]))
    cords = []
    KING_CORDS.each { |k| cords << [current_king[0] + k[0], current_king[1] + k[1]] }
    cords.each { |k| return true if k == end_cord }
    false
  end

  # promotions
  def promotion?(turn)
    pawn_list = []
    if turn
      pawn = @piece.white
      promo = PROMOTION_SQUARE_WHITE
    else
      pawn = @piece.black
      promo = PROMOTION_SQUARE_BLACK
    end
    @new_board.each_with_index { |p, i| pawn_list << i if p == pawn[5] }
    pawn_list.each { |i| @new_board[i] = pawn[1] if promo.include?(i) }
  end

  # checkmate
  def checkmate(turn, board)
    cm_king_moves(turn) == 'checkmate' && cm_block(board) == 'checkmate'
  end

  def cm_king_moves(turn)
    current_king = @new_board.index(@own_pieces[0])
    current_king_cords = @notation.cord_from_number(@new_board.index(@own_pieces[0]))
    possible_king_moves = []
    escape = []
    @checkers = []
    KING_CORDS.each do |k|
      possible_king_moves << @notation.number_from_cord([current_king_cords[0] + k[0], current_king_cords[1] + k[1]])
    end
    possible_king_moves.compact!
    possible_king_moves.each do |move|
      test_moves(current_king, move) if basic_move_rules(current_king, move, turn)
      escape << true if piece_access(king_coordinates(@test_board), @test_board) == false
    end
    @checkers = []
    return 'checkmate' unless escape.any?
  end

  def cm_block(board)
    escape = []
    piece_access(king_coordinates(board), board)
    movement(@checkers[0], king_coordinates(board))
    @checkers = []
    @full_path.each { |square| escape << square if piece_access(square, board, @own_pieces) == true }
    return 'checkmate' unless escape.any?

    @checkers = []
  end

  def movement(first, last)
    @full_path = []
    while first != last
      @full_path << first = if first[0] < last[0] && first[1] < last[1]
                              [first[0] + 1, first[1] + 1]
                            elsif first[0] > last[0] && first[1] > last[1]
                              [first[0] - 1, first[1] - 1]
                            elsif first[0] > last[0] && first[1] < last[1]
                              [first[0] - 1, first[1] + 1]
                            elsif first[0] < last[0] && first[1] > last[1]
                              [first[0] + 1, first[1] - 1]
                            elsif first[0] < last[0] && first[1] == last[1]
                              [first[0] + 1, first[1]]
                            elsif first[0] > last[0] && first[1] == last[1]
                              [first[0] - 1, first[1]]
                            elsif first[0] == last[0] && first[1] < last[1]
                              [first[0], first[1] + 1]
                            else
                              [first[0], first[1] - 1]
                            end
    end
    @full_path.pop
  end
end
