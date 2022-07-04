# frozen_string_literal: true

require_relative 'pieces'
require_relative 'notation'
require_relative 'cords_module'

# accepts player inputs to update the board and pieces
class Moves
  attr_accessor(:new_board)

  include Coordinates

  def initialize
    @piece = Pieces.new
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

  def helper_board_square_numbers
    positions = [*0..80]
    positions.map! { |f| format('%02d', f) }
  end

  def make_moves(start_square, end_square)
    @new_board[end_square] = @new_board[start_square]
    @new_board[start_square] = ' '
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

  # piece specific
  def piece_picker(start_cord, end_cord, start_square)
    case @new_board[start_square]
    when @piece.white[0], @piece.black[0]
      king(start_cord, end_cord)
    when @piece.white[1], @piece.black[1]
      queen(start_cord, end_cord)
    when @piece.white[2], @piece.black[2]
      rook(start_cord, end_cord)
    when @piece.white[3], @piece.black[3]
      bishop(start_cord, end_cord)
    when @piece.white[4], @piece.black[4]
      knight(start_cord, end_cord)
    when @piece.white[5], @piece.black[5]
      pawn(start_cord, end_cord, start_square)
    end
  end

  # knights
  def knight(start_cord, end_cord)
    KNIGHT_CORDS.include?([start_cord[0] - end_cord[0], start_cord[1] - end_cord[1]])
  end

  # bishops
  def bish_full_path(start_cord, end_cord)
    @bish_paths = []
    n = 1
    distance = (end_cord[0] - start_cord[0]).abs
    while n < distance
      @bish_paths << if start_cord[0] < end_cord[0] && start_cord[1] < end_cord[1]
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

  def bish_clear_path
    notation = Notation.new
    notation.create_board_coordinates
    @bish_paths.each do |c|
      next_square = notation.number_from_cord(c)
      return false if @new_board[next_square] != ' '
    end
    true
  end

  def bishop(start_cord, end_cord)
    bish_full_path(start_cord, end_cord)
    bishop_test = (end_cord[0] - start_cord[0]).abs == (end_cord[1] - start_cord[1]).abs
    bishop_test if bish_clear_path
  end

  # rooks
  def rook_full_path(start_cord, end_cord)
    @rook_paths = []
    i = 1
    diff = [(end_cord[0] - start_cord[0]).abs, (end_cord[1] - start_cord[1]).abs]
    while i < diff.max
      @rook_paths << if diff[0].positive? && start_cord[0] < end_cord[0]
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

  def rook_clear_path
    notation = Notation.new
    notation.create_board_coordinates
    @rook_paths.each do |c|
      next_square = notation.number_from_cord(c)
      return false if @new_board[next_square] != ' '
    end
    true
  end

  def rook(start_cord, end_cord)
    @rook_test = (start_cord[0] - end_cord[0]).zero? || (start_cord[1] - end_cord[1]).zero?
    rook_full_path(start_cord, end_cord)
    @rook_test if rook_clear_path
  end

  # king
  def king(start_cord, end_cord)
    KING_CORDS.include?([start_cord[0] - end_cord[0], start_cord[1] - end_cord[1]])
  end

  def queen(start_cord, end_cord)
    if @rook_test
      rook_full_path(start_cord, end_cord)
      rook_clear_path
    else
      bish_full_path(start_cord, end_cord)
      bish_clear_path
    end
  end

  # pawns
  def pawn(start_cord, end_cord, start_square)
    if @new_board[start_square] == @piece.white[5]
      cords = PAWN_WHITE_CORDS
      start_num = 6
    else
      cords = PAWN_BLACK_CORDS
      start_num = 1
    end
    pawn_test = cords[0] == [start_cord[0] - end_cord[0], start_cord[1] - end_cord[1]]
    not_yet_moved = cords[1] == [start_cord[0] - end_cord[0], start_cord[1] - end_cord[1]]
    capture_test = cords[2..3].include?([start_cord[0] - end_cord[0], start_cord[1] - end_cord[1]])
    pawn_moves(pawn_test, not_yet_moved, capture_test, start_cord, end_cord, start_num)
  end

  def pawn_moves(pawn_test, not_yet_moved, capture_test, start_cord, end_cord, start_num)
    if start_cord[1] == start_num
      (pawn_test || not_yet_moved) unless pawn_capture(end_cord) || (capture_test if pawn_capture(end_cord))
    else
      (pawn_test unless pawn_capture(end_cord)) || (capture_test if pawn_capture(end_cord))
    end
  end

  def pawn_capture(end_cord)
    notation = Notation.new
    notation.create_board_coordinates
    end_square = notation.number_from_cord(end_cord)
    true if @new_board[end_square] != ' '
  end

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

  # checking
  def king_coordinates
    square = @new_board.index(@piece.black[0])
    notation = Notation.new
    notation.create_board_coordinates
    notation.cord_from_number(square)
  end

  def king_checks
    knight_check(king_coordinates)
  end

  def knight_full_paths(king_cord)
    @knight_paths = []
    KNIGHT_CORDS.each { |c| @knight_paths << ([king_cord[0] + c[0], king_cord[1] + c[1]]) }
  end

  def knight_check(king_cord)
    knight_full_paths(king_cord)
    notation = Notation.new
    notation.create_board_coordinates
    next_square = []
    @knight_paths.each { |c| next_square << notation.number_from_cord(c) }
    next_square.compact!
    next_square.each { |s| puts 'Check!' if @new_board[s] == @piece.white[4] || @new_board[s] == @piece.black[4] }
  end
end
