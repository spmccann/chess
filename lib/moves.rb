# frozen_string_literal: true

require_relative 'pieces'
require_relative 'notation'
require_relative 'cords_module'
require_relative 'position'

# updates the moves in the position
class Moves < Position
  attr_accessor(:test_board)

  include Coordinates

  def initialize
    super
    @piece = Pieces.new
    @notation = Notation.new
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
end
