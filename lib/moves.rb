# frozen_string_literal: true

require_relative 'pieces'
require_relative 'notation'
require_relative 'cords_module'

# accepts player inputs to update the board and pieces positions
class Moves
  attr_accessor(:new_board, :test_board, :castle_rights, :checkers)

  include Coordinates

  def initialize
    setup
  end

  def setup
    @piece = Pieces.new
    @notation = Notation.new
    @castle_rights = [0, 0, 0, 0]
    @checkers = []
    @passant_possible = []
    @passant_turns = []
    @new_board =
      ['8', @piece.black[2], @piece.black[4], @piece.black[3], @piece.black[1], @piece.black[0], @piece.black[3], @piece.black[4], @piece.black[2],
       '7', @piece.black[5], @piece.black[5], @piece.black[5], @piece.black[5], @piece.black[5], @piece.black[5], @piece.black[5], @piece.black[5],
       '6', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
       '5', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
       '4', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
       '3', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
       '2', @piece.white[5], @piece.white[5], @piece.white[5], @piece.white[5], @piece.white[5], @piece.white[5], @piece.white[5], @piece.white[5],
       '1', @piece.white[2], @piece.white[4], @piece.white[3], @piece.white[1], @piece.white[0], @piece.white[3], @piece.white[4], @piece.white[2],
       '▦', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H']
  end

  def reset_game
    setup
  end

  # update the board
  def make_moves(start_square, end_square)
    @new_board[end_square] = @new_board[start_square]
    @new_board[start_square] = ' '
  end

  # playing a move on a test board to catch a move that walks into check
  def test_moves(start_square, end_square)
    @test_board = @new_board.dup
    @test_board[end_square] = @test_board[start_square]
    @test_board[start_square] = ' '
  end

  # general rules for movement
  def basic_move_rules(start_square, end_square, turn)
    start_piece_exists(start_square) && end_piece_not_same_color(end_square,
                                                                 turn) && turn_color_match(start_square,
                                                                                           turn) && end_square_index_not_board_label(end_square)
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

  def end_square_index_not_board_label(end_square)
    BOARD_LABELS.each { |l| return false if end_square == @new_board.index(l) }
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

  # checks if any pieces are way of the move
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
    pawn_loader(cords, start_num, start_cord, end_cord, mid_cord, board)
  end

  def pawn_loader(cords, start_num, start_cord, end_cord, mid_cord, board)
    pawn_forward_one(cords, start_cord, end_cord,
                     board) || pawn_forward_two(cords, start_num, start_cord, end_cord, mid_cord,
                                                board) || pawn_capture(cords, start_cord, end_cord,
                                                                       board) || en_passant(cords, start_cord,
                                                                                            end_cord, mid_cord, board)
  end

  def pawn_forward_one(cords, start_cord, end_cord, board)
    pawn_test = [start_cord[0] - end_cord[0], start_cord[1] - end_cord[1]]
    true if cords[0] == pawn_test && no_pawn_ahead(end_cord, board)
  end

  def pawn_forward_two(cords, start_num, start_cord, end_cord, mid_cord, board)
    pawn_test = [start_cord[0] - end_cord[0], start_cord[1] - end_cord[1]]
    @passant_possible << end_cord if start_cord[1] == start_num && cords[1] == pawn_test && no_pawn_ahead(end_cord,
                                                                                                          board) && pawn_mid(
                                                                                                            mid_cord, board
                                                                                                          )
  end

  def pawn_capture(cords, start_cord, end_cord, board)
    pawn_test = [start_cord[0] - end_cord[0], start_cord[1] - end_cord[1]]
    board[@notation.number_from_cord(end_cord)] != ' ' && cords[2..3].include?(pawn_test)
  end

  # checking that there's no piece one square ahead if moving 2 squares
  def pawn_mid(mid_cord, board)
    board[@notation.number_from_cord(mid_cord)] == ' '
  end

  def no_pawn_ahead(end_cord, board)
    board[@notation.number_from_cord(end_cord)] == ' '
  end

  def en_passant(cords, start_cord, end_cord, mid_cord, board)
    pawn_test = [start_cord[0] - end_cord[0], start_cord[1] - end_cord[1]]
    opp_take_pawn = board[@notation.number_from_cord(mid_cord)] == @opp_pieces[5]
    mid_cord[1]
    start_spot = mid_cord[1] == if @own_pieces == @piece.white
                                  3
                                else
                                  4
                                end

    unless @passant_possible[0] == mid_cord && cords[2..3].include?(pawn_test) && opp_take_pawn && start_spot
      return false
    end

    board[@notation.number_from_cord(mid_cord)] = ' '
    true
  end

  def passant_control(turn)
    @passant_turns << turn unless @passant_possible.empty?
    return unless @passant_turns.length > 1

    @passant_possible = []
    @passant_turns = []
  end

  # castling
  def castle(player_move, turn)
    select_castle(player_move, turn)
    if valid_castle && castling_rights(player_move, turn) && attack_on_castle_squares && no_castle_in_check
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

  # squares between king and rook have to be empty
  def valid_castle
    if @moveset.length == 4
      @new_board[@moveset[0]] == ' ' && @new_board[@moveset[2]] == ' '
    else
      @new_board[@moveset[0]] == ' ' && @new_board[@moveset[2]] == ' ' && @new_board[@moveset[4]] == ' '
    end
  end

  # counts moves by the king or rook to see if castling rights are lost
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

  # verifies that no opponent piece has vision on squares between a castle manuveur
  def attack_on_castle_squares
    result = []
    result << false if piece_access(@notation.cord_from_number(@moveset[0]), @new_board)
    @checkers = []
    result << false if piece_access(@notation.cord_from_number(@moveset[2]), @new_board)
    @checkers = []
    result << false if @moveset.length > 4 && piece_access(@notation.cord_from_number(@moveset[4]), @new_board)
    @checkers = []
    true if result.empty?
  end

  def no_castle_in_check
    piece_access(king_coordinates(@new_board), @new_board) == false
  end

  def castle_move
    @new_board[@moveset[0]] = @new_board[@moveset[1]]
    @new_board[@moveset[1]] = ' '
    @new_board[@moveset[2]] = @new_board[@moveset[3]]
    @new_board[@moveset[3]] = ' '
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

  # checks / access to specified square
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

  def find_all_pieces_by_type(num, board, side)
    @all_pieces = []
    board.each_with_index { |p, i| @all_pieces << @notation.cord_from_number(i) if p == side[num] }
  end

  def queen_access(end_cord, board, side)
    find_all_pieces_by_type(1, board, side)
    @all_pieces.each { |q| @checkers << q if queen(q, end_cord, board) }
  end

  def rook_access(end_cord, board, side)
    find_all_pieces_by_type(2, board, side)
    @all_pieces.each { |r| @checkers << r if rook(r, end_cord, board) }
  end

  def bishop_access(end_cord, board, side)
    find_all_pieces_by_type(3, board, side)
    @all_pieces.each { |b| @checkers << b if bishop(b, end_cord, board) }
  end

  def knight_access(end_cord, board, side)
    find_all_pieces_by_type(4, board, side)
    @all_pieces.each { |n| @checkers << n if knight(n, end_cord) }
  end

  def pawn_access(end_cord, board, side)
    find_all_pieces_by_type(5, board, side)
    @all_pieces.each { |p| @checkers << p if pawn(p, end_cord, board) }
  end

  def no_king_check(board, end_cord)
    current_king = @notation.cord_from_number(board.index(@opp_pieces[0]))
    cords = []
    KING_CORDS.each { |k| cords << [current_king[0] + k[0], current_king[1] + k[1]] }
    cords.each { |k| return true if k == end_cord }
    false
  end

  # checkmate
  def checkmate(turn, board)
    checkmate_king_moves(turn) == 'checkmate' && checkmate_block(board) == 'checkmate' && checkmate_capture(board)
  end

  def checkmate_king_moves(turn)
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
      next unless basic_move_rules(current_king, move, turn)

      test_moves(current_king, move)
      escape << true if piece_access(king_coordinates(@test_board), @test_board) == false
      @checkers = []
    end
    return 'checkmate' unless escape.any?
  end

  def checkmate_block(board)
    escape = []
    piece_access(king_coordinates(board), board)
    movement(@checkers[0], king_coordinates(board))
    @checkers = []
    @full_path.each { |square| escape << square if piece_access(square, board, @own_pieces) == true }
    @checkers = []
    return 'checkmate' unless escape.any?
  end

  def checkmate_capture(board)
    piece_access(king_coordinates(@new_board), board)
    capture_piece = @checkers[0]
    @checkers = []
    piece_access(capture_piece, board, @own_pieces) == false
  end

  # collects the path between the attack piece and king to be used for checkmate_block
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

  def dead_position
    pieces_left = [@piece.white[3], @piece.white[4], @piece.black[3], @piece.black[4]]
    @new_board.count(' ') == 62 || (@new_board.count(' ') == 61 && @new_board.each do |s|
                                      true if pieces_left.include?(s)
                                    end)
  end

  def stalemate(board, turn)
    return true if all_knight_moves(board, turn)

    false
  end

  # def all_knight_moves(turn)
  #   current_knight = @new_board.index(@own_pieces[4])
  #   current_knight_cords = @notation.cord_from_number(@new_board.index(@own_pieces[4]))
  #   possible_knight_moves = []
  #   escape = []
  #   KNIGHT_CORDS.each do |k|
  #     possible_knight_moves << @notation.number_from_cord([current_knight_cords[0] + k[0],
  #                                                          current_knight_cords[1] + k[1]])
  #   end
  #   possible_knight_moves.compact!
  #   possible_knight_moves.each { |move| escape << move if basic_move_rules(current_knight, move, turn) }
  #   p possible_knight_moves
  #   p escape
  #   return true unless escape.any?
  # end

  def all_knight_moves(board, turn)
    find_all_pieces_by_type(4, board, @own_pieces)
    escape = []
    KNIGHT_CORDS.each do |k|
      @all_pieces.each do |p|
        possible_knight = [p[0] + k[0], p[1] + k[1]]
        pos_knight_num = @notation.number_from_cord(possible_knight)
        current_knight_num = @notation.number_from_cord(p)
        next unless !(pos_knight_num.nil? || current_knight_num.nil?) && basic_move_rules(current_knight_num, pos_knight_num,
                                                                                          turn)

        escape << possible_knight if knight_access(possible_knight, board, @own_pieces)
        @checkers = []
      end
    end
    p escape
    return true unless escape.any?
  end
end
