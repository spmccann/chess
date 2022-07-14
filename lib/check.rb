# frozen_string_literal: true

require_relative 'pieces'
require_relative 'notation'
require_relative 'each_piece'

# checks for checks
class Check < EachPiece

  def initialize
    super
    @piece = Pieces.new
    @notation = Notation.new
  end

  # checks
  def king_checks(board)
    return true if knight_check(king_coordinates(board), board) == 'check'
    return true if bishop_check(king_coordinates(board), board) == 'check'
    return true if rook_check(king_coordinates(board), board) == 'check'
    return true if queen_check(king_coordinates(board), board) == 'check'
    return true if pawn_check(king_coordinates(board), board) == 'check'

    false
  end

  def king_coordinates(board)
    @notation.cord_from_number(board.index(@king_color[0]))
  end

  def piece_color(turn)
    @attack_color = turn ? @piece.black : @piece.white
    @king_color = turn ? @piece.white : @piece.black
  end

  # create an array of cords of the requested piece type
  def find_all_piece_by_type(num, board)
    @all_pieces = []
    board.each_with_index { |p, i| @all_pieces << @notation.cord_from_number(i) if p == @attack_color[num] }
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

  def pawn_check(king_cord, board)
    find_all_piece_by_type(5, board)
    @all_pieces.each { |n| return 'check' if pawn(n, king_cord, board) }
  end
end
