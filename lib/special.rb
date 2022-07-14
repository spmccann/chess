# frozen_string_literal: true

require_relative 'pieces'
require_relative 'notation'
require_relative 'cords_module'
require_relative 'position'

# special maneuvers
class SpecialMoves < Position
  attr_accessor(:castle_rights)

  include Coordinates

  def initialize
    super
    @piece = Pieces.new
    @notation = Notation.new
    @castle_rights = [0, 0, 0, 0]
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

  # promotions
  def promotion?(turn)
    pawn_list = []
    if turn
      pawn = @piece.white[5]
      promo = PROMOTION_SQUARE_BLACK
    else
      pawn = @piece.black[5]
      promo = PROMOTION_SQUARE_WHITE
    end
    @new_board.each_with_index { |p, i| pawn_list << i if p == pawn }
    pawn_list.each { |i| @new_board[i] = @piece.white[1] if promo.include?(i) }
  end
end
