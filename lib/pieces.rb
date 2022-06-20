# frozen_string_literal: true

require 'colorize'

# chess pieces
class Pieces
  attr_accessor(:white, :black)

  def initialize
    @white = ['♔', '♕', '♖', '♗', '♘', '♙']
    @black = ['♚', '♛', '♜', '♝', '♞', '♟']
  end
end
