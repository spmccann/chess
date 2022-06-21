# frozen_string_literal: true

# terminal messages to players
class Messages
  def initialize
    @player1 = ''
    @player2 = ''
  end

  def welcome
    puts 'Chess'
  end

  def names
    puts "Please enter Player 1's name"
    @player1 = gets.chomp
    puts "Please enter Player 2's name"
    @player2 = gets.chomp
  end

  def greeting
    puts "Hello #{@player1} and #{@player2}. #{@player1} has the white pieces and #{@player2} has the black pieces.  "
  end

  def move(turn)
    turn ? puts("#{@player1}, enter a move.") : puts("#{@player2}, enter a move.")
  end

  def invalid_move
    # puts 'Enter your move in the format [A-H][1-8]-[A-H][1-8]. For example, E2-E4.'
    puts 'Invalid move. Please enter again.'
  end

  def next_turn
    puts "Chess: #{@player1} vs. #{@player2}\n"
  end
end
