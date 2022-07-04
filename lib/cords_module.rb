# frozen_string_literal: true

# piece movement coordinates
module Coordinates
  KNIGHT_CORDS = [[-2, -1], [-2, 1], [-1, 2], [-1, -2], [1, -2], [1, 2], [2, -1], [2, 1]].freeze
  PAWN_WHITE_CORDS = [[0, 1], [0, 2], [-1, 1], [1, 1]].freeze
  PAWN_BLACK_CORDS = [[0, -1], [0, -2], [-1, -1], [1, -1]].freeze
  KING_CORDS = [[0, 1], [1, 0], [-1, 0], [0, -1]].freeze
end
