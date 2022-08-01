# frozen_string_literal: true

require_relative 'pieces'
require_relative 'notation'
require_relative 'cords_module'

# accepts player inputs to update the board and pieces positions
class Moves
  attr_accessor(:new_board, :test_board, :castle_rights, :move_history)

  include Coordinates

  def initialize
    setup
  end

  def setup
    @piece = Pieces.new
    @notation = Notation.new
    @castle_rights = [0, 0, 0, 0]
    @checkers = []
    @move_history = []
    @special = false
    @escape = []
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
  def make_moves(start_square, end_square, turn)
    @move_history << [start_square, end_square]
    @new_board[end_square] = @new_board[start_square]
    @new_board[start_square] = ' '
    make_special_moves(end_square, turn) if @special
  end

  def make_special_moves(end_square, turn)
    end_cord = @notation.cord_from_number(end_square)
    mid_cord = if turn
                 [end_cord[0], end_cord[1] + 1]
               else
                 [end_cord[0], end_cord[1] - 1]
               end
    @new_board[@notation.number_from_cord(mid_cord)] = ' '
    @special = false
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
    return true if no_king_check(board, end_cord)

    return true if KING_CORDS.include?([start_cord[0] - end_cord[0], start_cord[1] - end_cord[1]])

    false
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

  def knight(start_cord, end_cord, _board = [])
    KNIGHT_CORDS.include?([start_cord[0] - end_cord[0], start_cord[1] - end_cord[1]])
  end

  def pawn(start_cord, end_cord, board)
    if board[@notation.number_from_cord(start_cord)] == @piece.white[5]
      cords = PAWN_WHITE_CORDS
      start_num = 6
      mid_cord = if (end_cord[1] + 1) < 8
                   [end_cord[0], end_cord[1] + 1]
                 else
                   [1, 0]
                 end
    else
      cords = PAWN_BLACK_CORDS
      start_num = 1
      mid_cord = if (end_cord[1] - 1).positive?
                   [end_cord[0], end_cord[1] - 1]
                 else
                   [1, 0]
                 end
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
    true if start_cord[1] == start_num && cords[1] == pawn_test && no_pawn_ahead(end_cord,
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
    start_spot = mid_cord[1] == if @own_pieces == @piece.white
                                  3
                                else
                                  4
                                end
    return false unless cords[2..3].include?(pawn_test) && opp_take_pawn && start_spot && last_move_two(mid_cord)

    @special = true
    true
  end

  def last_move_two(mid_cord)
    last = @move_history[-1]
    start_cord = @notation.cord_from_number(last[0])
    end_cord = @notation.cord_from_number(last[1])
    pawn_test = (start_cord[1] - end_cord[1]).abs == 2
    is_pawn = @new_board[last[1]] == @opp_pieces[5]
    adjacent = mid_cord == end_cord
    pawn_test && is_pawn && adjacent
  end

  # castling
  def castle(player_move, turn)
    select_castle(player_move, turn)
    if valid_castle && castling_rights(player_move, turn) && attack_on_castle_squares && no_castle_in_check
      castle_move
      @move_history << player_move
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
    result << false if piece_access(@notation.cord_from_number(@moveset[2]), @new_board)
    result << false if @moveset.length > 4 && piece_access(@notation.cord_from_number(@moveset[4]), @new_board)
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

  def piece_methods(piece_num, p, possible, board)
    case piece_num
    when 0
      king(p, possible, board)
    when 1
      queen(p, possible, board)
    when 2
      rook(p, possible, board)
    when 3
      bishop(p, possible, board)
    when 4
      knight(p, possible, board)
    when 5
      pawn(p, possible, board)
    end
  end

  def king_coordinates(board)
    @notation.cord_from_number(board.index(@own_pieces[0]))
  end

  def piece_color(turn)
    @opp_pieces = turn ? @piece.black : @piece.white
    @own_pieces = turn ? @piece.white : @piece.black
  end

  # checks / access to specified square
  def piece_access(end_cord, board, side = @opp_pieces)
    @checkers = []
    all_access(end_cord, board, side)
    return true unless @checkers.empty?

    false
  end

  def find_all_pieces_by_type(num, board, side)
    @all_pieces = []
    board.each_with_index { |p, i| @all_pieces << @notation.cord_from_number(i) if p == side[num] }
  end

  def all_access(end_cord, board, side)
    all = 0
    while all < 6
      find_all_pieces_by_type(all, board, side)
      @all_pieces.each { |p| @checkers << p if piece_methods(all, p, end_cord, board) }
      all += 1
    end
  end

  def no_king_check(board, end_cord)
    current_king = @notation.cord_from_number(board.index(@opp_pieces[0]))
    cords = []
    KING_CORDS.each { |k| cords << [current_king[0] + k[0], current_king[1] + k[1]] }
    cords.each { |k| return true if k == end_cord }
    false
  end

  def dead_position
    pieces_left = [@piece.white[3], @piece.white[4], @piece.black[3], @piece.black[4]]
    left = []
    @new_board.each { |s| left << s if pieces_left.include?(s) }
    @new_board.count(' ') == 62 || (@new_board.count(' ') == 61 && left.any?)
  end

  def mate(board, turn)
    @escape = []
    all_stale(board, turn)
    no_escape_into_check
    return true if @escape.empty?

    false
  end

  def cords_stale(cord_num, turn)
    case cord_num
    when 0
      KING_CORDS
    when 1
      QUEEN_CORDS
    when 2
      ROOK_CORDS
    when 3
      BISHOP_CORDS
    when 4
      KNIGHT_CORDS
    when 5
      if turn
        PAWN_BLACK_CORDS
      else
        PAWN_WHITE_CORDS
      end
    end
  end

  def all_stale(board, turn)
    all = 0
    while all < 6
      find_all_pieces_by_type(all, board, @own_pieces)
      cords_stale(all, turn).each do |c|
        @all_pieces.each do |p|
          possible = [p[0] + c[0], p[1] + c[1]]
          possible_num = @notation.number_from_cord(possible)
          current_num = @notation.number_from_cord(p)
          next unless !possible_num.nil? && basic_move_rules(current_num, possible_num, turn)

          @escape << [p, possible] if piece_methods(all, p, possible, board)
        end
      end
      all += 1
    end
  end

  def no_escape_into_check
    @escape.select! do |move|
      test_moves(@notation.number_from_cord(move[0]), @notation.number_from_cord(move[1]))
      move if piece_access(king_coordinates(@test_board), @test_board) == false
    end
  end

  def computer_player(board, turn)
    @notation.numbers_to_algebraic
    mate(board, turn)
    add_castle_com(turn)
    move = @escape.sample
    start_square = @notation.number_from_cord(move[0])
    end_square = @notation.number_from_cord(move[1])
    "#{@notation.table.key(start_square)}-#{@notation.table.key(end_square)}"
  end

  def add_castle_com(turn)
    @escape.push('0-0') if castle('0-0', turn)
    @escape.push('0-0-0') if castle('0-0-0', turn)
  end
end
