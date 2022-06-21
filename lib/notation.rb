# frozen_string_literal: true

# chess notation for user
class Notation
  attr_accessor(:table)

  def initialize
    @table = {}
    @letter = %w[A B C D E F G H]
    @num = [*1..8]
    @ranks = [*0..8]
    @files = [*0..8]
    @board = []
  end

  def create_board_coordinates
    i = 0
    while i < 9
      @board += @ranks.map { |r| [@files[r], i] }
      i += 1
    end
  end

  def numbers_to_algebraic
    number = 1
    i = 0
    h = 7
    while number < 72
      @table["#{@letter[i]}#{@num[h]}"] = number unless (number % 9).zero?
      number += 1
      h -= 1 if (number % 9).zero?
      if (number % 9).zero?
        i = -1
      else
        i += 1
      end
    end
    @table
  end

  def numbers_to_coordinates
    @board[@table['A8']]
  end
end
