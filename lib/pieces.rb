# frozen_string_literal: true

# chess pieces
class Pieces
  attr_accessor(:white, :black)

  def initialize
    @white = ['♔', '♕', '♖', '♗', '♘', '♙']
    @black = ['♚', '♛', '♜', '♝', '♞', '♟']
  end
end
