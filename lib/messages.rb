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

  def ask_move
    gets.chomp.upcase
  end

  def options(move)
    move == 'OPTIONS'
  end

  def ask_option
    gets.chomp.upcase
  end

  def options_menu
    puts 'What option would you like?'
    puts "Press 'S' to save, 'N' to start new game, 'L' to load game or 'Q' to quit, Any other key to exit."
  end

  def your_move(turn)
    turn ? puts("#{@player1}, enter a move.") : puts("#{@player2}, enter a move.")
  end

  def invalid_notation
    puts 'Enter your move in the format [A-H][1-8]-[A-H][1-8]. For example, E2-E4.'
  end

  def invalid_chess_move
    puts 'Invalid chess move.'
  end

  def next_turn
    puts "Chess: #{@player1} vs. #{@player2}\n"
  end
end
