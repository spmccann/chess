# frozen_string_literal: true

require_relative 'pieces'
require_relative 'notation'
require_relative 'cords_module'
require_relative 'moves'

# rules for each piece
class EachPiece < Moves
  include Coordinates

  def initialize
    super
    @piece = Pieces.new
    @notation = Notation.new
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
      pawn(start_cord, end_cord, board)
    end
  end

  # checks if any pieces are way of requested move
  def clear_path?(board)
    @path.each { |c| return false if board[@notation.number_from_cord(c)] != ' ' }
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
end
