# frozen_string_literal: true

require_relative 'pieces'
require_relative 'notation'

# accepts player inputs to update the board and pieces
class Moves < Notation
  attr_accessor(:new_board)

  def initialize
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
    knight(start_cord, end_cord, start_square) && bishop(start_cord, end_cord, start_square)
  end

  def knight(start_cord, end_cord, start_square)
    cords = [[-2, -1], [-2, 1], [-1, 2], [-1, -2], [-1, 2], [1, -2], [1, 2], [2, -1], [2, 1]]
    knight_test = cords.include?([start_cord[0] - end_cord[0], start_cord[1] - end_cord[1]])
    if @new_board[start_square] == @p.white[4] || @new_board[start_square] == @p.black[4]
      knight_test
    else
      true
    end
  end

  def bish_start_to_end_path(start_cord, end_cord)
    @paths = []
    n = 1
    distance = (end_cord[0] - start_cord[0]).abs
    while n < distance
      if start_cord[0] < end_cord[0] && start_cord[1] < end_cord[1]
        @paths << [start_cord[0] + n, start_cord[1] + n]
      elsif start_cord[0] < end_cord[0] && start_cord[1] > end_cord[1]
        @paths << [start_cord[0] + n, start_cord[1] - n]
      elsif start_cord[0] > end_cord[0] && start_cord[1] < end_cord[1]
        @paths << [start_cord[0] - n, start_cord[1] + n]
      else
        @paths << [start_cord[0] - n, start_cord[1] - n]
      end
      n += 1
    end
    p @paths
  end

  def bish_clear_path
    notation = Notation.new
    notation.create_board_coordinates
    @paths.each do |c|
      next_square = notation.number_from_cord(c)
      return false if @new_board[next_square] != ' '
    end
    true
  end

  def bishop(start_cord, end_cord, start_square)
    bish_start_to_end_path(start_cord, end_cord)
    bishop_test = (end_cord[0] - start_cord[0]).abs == (end_cord[1] - start_cord[1]).abs
    if new_board[start_square] == @p.white[3] || @new_board[start_square] == @p.black[3]
      bishop_test if bish_clear_path
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
