# frozen_string_literal: true

require_relative 'pieces'
require_relative 'notation'
require_relative 'cords_module'

# accepts player inputs to update the board and pieces positions
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

  # def helper_board_square_numbers
  #   positions = [*0..80]
  #   positions.map! { |f| format('%02d', f) }
  # end

  # update the board
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

  # piece specific move rules
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

  # checks if any pieces are way of requested move
  def clear_path?
    notation = Notation.new
    @path.each { |c| return false if @new_board[notation.number_from_cord(c)] != ' ' }
  end

  # king
  def king(start_cord, end_cord)
    KING_CORDS.include?([start_cord[0] - end_cord[0], start_cord[1] - end_cord[1]])
  end

  # queen
  def queen(start_cord, end_cord)
    rook(start_cord, end_cord) || bishop(start_cord, end_cord)
  end

  # rooks
  def rook(start_cord, end_cord)
    return unless (start_cord[0] - end_cord[0]).zero? || (start_cord[1] - end_cord[1]).zero?

    rook_path(start_cord, end_cord)
    clear_path?
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

  # bishops
  def bishop(start_cord, end_cord)
    return unless (end_cord[0] - start_cord[0]).abs == (end_cord[1] - start_cord[1]).abs

    bishop_path(start_cord, end_cord)
    clear_path?
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

  # knights
  def knight(start_cord, end_cord)
    KNIGHT_CORDS.include?([start_cord[0] - end_cord[0], start_cord[1] - end_cord[1]])
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
    pawn_moves(cords, start_num, start_cord, end_cord)
  end

  def pawn_moves(cords, start_num, start_cord, end_cord)
    forward_one = cords[0] == [start_cord[0] - end_cord[0], start_cord[1] - end_cord[1]]
    forward_two = cords[1] == [start_cord[0] - end_cord[0], start_cord[1] - end_cord[1]]
    diag_capture = cords[2..3].include?([start_cord[0] - end_cord[0], start_cord[1] - end_cord[1]])
    if start_cord[1] == start_num
      (forward_one || forward_two) unless pawn_capture(end_cord) || (diag_capture if pawn_capture(end_cord))
    else
      forward_one || (diag_capture if pawn_capture(end_cord))
    end
  end

  def pawn_capture(end_cord)
    notation = Notation.new
    @new_board[notation.number_from_cord(end_cord)] != ' '
  end

  # checking
  def white_king_coordinates
    notation = Notation.new
    notation.cord_from_number(@new_board.index(@piece.white[0]))
  end

  def black_king_coordinates
    notation = Notation.new
    notation.cord_from_number(@new_board.index(@piece.black[0]))
  end

  def king_checks
    knight_check(black_king_coordinates)
  end

  def knight_full_paths(king_cord)
    @knight_paths = []
    KNIGHT_CORDS.each { |c| @knight_paths << ([king_cord[0] + c[0], king_cord[1] + c[1]]) }
  end

  def knight_check(king_cord)
    knight_full_paths(king_cord)
    notation = Notation.new
    next_square = []
    @knight_paths.each { |c| next_square << notation.number_from_cord(c) }
    next_square.compact!
    next_square.each { |s| puts 'Check!' if @new_board[s] == @piece.white[4] || @new_board[s] == @piece.black[4] }
  end

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
