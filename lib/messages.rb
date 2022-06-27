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

  def names_request
    puts 'Please enter player names to continue'
  end

  def names(one = gets.chomp, two = gets.chomp)
    @player1 = one
    @player2 = two
    [@player1, @player2]
  end

  def greeting
    puts "#{@player1} has the white pieces and #{@player2} has the black pieces.  "
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

  def confirmation(choice)
    case choice
    when 'S'
      puts 'Game Saved!'
    when 'N'
      puts 'Starting New Game...'
    when 'L'
      puts 'Game Loaded!'
    when 'Q'
      puts 'Quit Game. Goodbye'
    when 'H'
      help_menu
    end
  end

  def help_menu
    puts 'S - saves game'
    puts 'N - starts a new game'
    puts 'L - loads game'
    puts 'Q - quits the program'
    puts 'H - help menu'
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
    puts "Chess: #{@player1} vs. #{@player2}. Enter 'H' for all game options.\n"
  end
end
