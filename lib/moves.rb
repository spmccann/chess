# frozen_string_literal: true

require_relative 'pieces'
require_relative 'notation'

# accepts player inputs to update the board and pieces
class Moves < Notation
  attr_accessor(:new_board)

  def initialize
    super
    @p = Pieces.new
    @new_board =
      ['8', @p.black[2], @p.black[4], @p.black[3], @p.black[1], @p.black[0], @p.black[3], @p.black[4], @p.black[2],
       '7', @p.black[5], @p.black[5], @p.black[5], @p.black[5], @p.black[5], @p.black[5], @p.black[5], @p.black[5],
       '6', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
       '5', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
       '4', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
       '3', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
       '2', @p.white[5], @p.white[5], @p.white[5], @p.white[5], @p.white[5], @p.white[5], @p.white[5], @p.white[5],
       '1', @p.white[2], @p.white[4], @p.white[3], @p.white[1], @p.white[0], @p.white[3], @p.white[4], @p.white[2],
       ' ', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H']
  end

  def helper_board_square_numbers
    positions = [*0..80]
    positions.map! { |f| format('%02d', f) }
  end

  def basic_move_rules(start_square, end_square, turn)
    start_piece_exists(start_square) && end_piece_not_same_color(end_square,
                                                                 turn) && turn_color_match(start_square, turn)
  end

  def start_piece_exists(start_square)
    @new_board[start_square] != ' '
  end

  def end_piece_not_same_color(end_square, turn)
    turn ? !@p.white.include?(@new_board[end_square]) : !@p.black.include?(@new_board[end_square])
  end

  def turn_color_match(start_square, turn)
    turn ? @p.white.include?(@new_board[start_square]) : @p.black.include?(@new_board[start_square])
  end

  def make_moves(start_square, end_square)
    @new_board[end_square] = @new_board[start_square]
    @new_board[start_square] = ' '
  end

  # piece specific rules
  def piece_specific_rules(start_cord, end_cord, start_square)
    knight(start_cord, end_cord,
           start_square) && bishop(start_cord, end_cord,
                                   start_square) && rook(start_cord, end_cord,
                                                         start_square) && king(start_cord, end_cord,
                                                                               start_square) && queen(start_cord,
                                                                                                      end_cord, start_square)
  end

  def which_piece?(num, start_square)
    @new_board[start_square] == @p.white[num] || @new_board[start_square] == @p.black[num]
  end

  def knight(start_cord, end_cord, start_square)
    cords = [[-2, -1], [-2, 1], [-1, 2], [-1, -2], [-1, 2], [1, -2], [1, 2], [2, -1], [2, 1]]
    knight_test = cords.include?([start_cord[0] - end_cord[0], start_cord[1] - end_cord[1]])
    if which_piece?(4, start_square)
      knight_test
    else
      true
    end
  end

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

  def bishop(start_cord, end_cord, start_square)
    bish_full_path(start_cord, end_cord)
    bishop_test = (end_cord[0] - start_cord[0]).abs == (end_cord[1] - start_cord[1]).abs
    if which_piece?(3, start_square)
      bishop_test if bish_clear_path
    else
      true
    end
  end

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
    p @rook_paths
    @rook_paths.each do |c|
      next_square = notation.number_from_cord(c)
      return false if @new_board[next_square] != ' '
    end
    true
  end

  def rook(start_cord, end_cord, start_square)
    @rook_test = (start_cord[0] - end_cord[0]).zero? || (start_cord[1] - end_cord[1]).zero?
    rook_full_path(start_cord, end_cord)
    if which_piece?(2, start_square)
      @rook_test if rook_clear_path
    else
      true
    end
  end

  def king(start_cord, end_cord, start_square)
    cords = [[0, 1], [1, 0], [-1, 0], [0, -1]]
    king_test = cords.include?([start_cord[0] - end_cord[0], start_cord[1] - end_cord[1]])
    if which_piece?(0, start_square)
      king_test
    else
      true
    end
  end

  def queen(start_cord, end_cord, start_square)
    if which_piece?(1, start_square)
      if @rook_test
        rook_full_path(start_cord, end_cord)
        rook_clear_path
      else
        bish_full_path(start_cord, end_cord)
        bish_clear_path
      end
    else
      true
    end
  end

  def reset_board
    @new_board = ['8', @p.black[2], @p.black[4], @p.black[3], @p.black[1], @p.black[0], @p.black[3], @p.black[4], @p.black[2],
                  '7', @p.black[5], @p.black[5], @p.black[5], @p.black[5], @p.black[5], @p.black[5], @p.black[5], @p.black[5],
                  '6', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
                  '5', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
                  '4', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
                  '3', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
                  '2', @p.white[5], @p.white[5], @p.white[5], @p.white[5], @p.white[5], @p.white[5], @p.white[5], @p.white[5],
                  '1', @p.white[2], @p.white[4], @p.white[3], @p.white[1], @p.white[0], @p.white[3], @p.white[4], @p.white[2],
                  ' ', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H']
  end
end
