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
    puts 'Welcome, please enter player names to continue'
  end

  def names(one = gets.chomp, two = gets.chomp)
    @player1 = one
    @player2 = two
    [@player1, @player2]
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
    puts "'S' to save, 'N' to start new game, 'L' to load game or 'Q' to quit, Any other key to continue."
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
      puts 'Quiting Game. Goodbye'
    end
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
