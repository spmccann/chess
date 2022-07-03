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
    @start_square = ''
    @end_square = ''
  end

  def create_board_coordinates
    i = 0
    while i < 9
      @board += @ranks.map { |r| [@files[r], i] }
      i += 1
    end
  end

  def number_from_cord(square)
    @board.index(square)
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

  def notation_valid_format(move)
    move.length == 5 && @letter.include?(move[0]) && @num.include?(move[1].to_i) && move[2] == '-' && @letter.include?(move[3]) && @num.include?(move[4].to_i)
  end

  def submit_move(move)
    @start_square = move.split('-')[0]
    @end_square = move.split('-')[1]
  end

  def cords_start
    @board[@table[@start_square]]
  end

  def cords_end
    @board[@table[@end_square]]
  end

  def input_start
    @table[@start_square]
  end

  def input_end
    @table[@end_square]
  end
end
