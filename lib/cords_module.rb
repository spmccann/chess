# frozen_string_literal: true

# piece movement coordinates
module Coordinates
  KNIGHT_CORDS = [[-2, -1], [-2, 1], [-1, 2], [-1, -2], [1, -2], [1, 2], [2, -1], [2, 1]].freeze
  PAWN_WHITE_CORDS = [[0, 1], [0, 2], [-1, 1], [1, 1]].freeze
  PAWN_BLACK_CORDS = [[0, -1], [0, -2], [-1, -1], [1, -1]].freeze
  KING_CORDS = [[0, 1], [1, 0], [-1, 0], [0, -1], [1, 1], [1, -1], [-1, 1], [-1, -1]].freeze
  # ROOK_CORDS = [[1, 0], [2, 0], [3, 0], [4, 0], [5, 0], [6, 0], [7, 0], [0, 1], [0, 2], [0, 3], [0, 4], [0, 5], [0, 6],
  #              [0, 7], [-1, 0], [-2, 0], [-3, 0], [-4, 0], [-5, 0], [-6, 0], [-7, 0], [0, -1], [0, -2], [0, -3], [0, -4],
  #              [0, -5], [0, -6], [0, 7]].freeze
  # BISHOP_CORDS = [[1, 1], [2, 2], [3, 3], [4, 4], [5, 5], [6, 6], [7, 7], [-1, -1], [-2, -2], [-3, -3], [-4, -4],
  #                [-5, -5], [-6, -6], [-7, -7], [1, -1], [2, -2], [3, -3], [4, -4], [5, -5], [6, -6], [7, -7],
  #                [-1, 1], [-2, 2], [-3, 3], [-4, 4], [-5, 5], [-6, 6], [-7, 7]].freeze
  CASTLE_SHORT_WHITE = [70, 68, 69, 71].freeze
  CASTLE_SHORT_BLACK = [7, 5, 6, 8].freeze
  CASTLE_LONG_WHITE = [66, 68, 67, 64, 65].freeze
  CASTLE_LONG_BLACK = [3, 5, 4, 1, 2].freeze
end
