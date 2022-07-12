# frozen_string_literal: true

# terminal messages to players
class Messages
  def initialize
    @player1 = ''
    @player2 = ''
  end

  def welcome
    puts '♔ Chess ♚'
  end

  def names_request
    puts 'Enter player names for white and black'
  end

  def names(one = gets.chomp, two = gets.chomp)
    @player1 = one
    @player2 = two
    [@player1, @player2]
  end

  def greeting
    puts "white pieces: #{@player1} black pieces: #{@player2}  "
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
    when 'L'
      puts 'Game Loaded!'
    when 'Q'
      puts 'Quit Game. Goodbye'
    when 'H'
      help_menu
    end
  end

  def help_menu
    puts '------------------------'
    puts 'S - saves game'
    puts 'L - loads game'
    puts 'Q - quits the program'
    puts 'H - help menu'
    puts '------------------------'
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
    puts "-----------Chess-----------\n #{@player1} vs. #{@player2} |'H' for help\n"
  end

  def check(turn)
    turn ? puts("#{@player1}, you're in check!") : puts("#{@player2}, you're in check!")
  end
end
