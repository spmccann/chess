# frozen_string_literal: true

# terminal messages to players
class Messages
  attr_accessor(:turn, :player1, :player2)

  def initialize
    @player1 = ''
    @player2 = ''
  end

  def welcome
    puts '♔ Chess ♚'
  end

  def names_request
    puts 'Enter names one at a time for white and black. "com" for a computer opponent'
  end

  def names(one = gets.chomp, two = gets.chomp)
    @player1 = one
    @player2 = two
    [@player1, @player2]
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
      puts 'Quit Game.'
    when 'H'
      help_menu
    end
  end

  def help_menu
    puts '------------------------'
    puts 'S - saves game'
    puts 'L - loads game'
    puts 'R - resign game'
    puts 'D - draw offer'
    puts 'Q - quits the program'
    puts 'H - help menu'
    puts '------------------------'
  end

  def your_move(turn)
    if turn
      puts("#{@player1}, enter a move.")
      @player1
    else
      puts("#{@player2}, enter a move.")
      @player2
    end
  end

  def invalid_notation
    puts 'Enter your move in the format [A-H][1-8]-[A-H][1-8]. For example, E2-E4. 0-0 and 0-0-0 for short/long castle'
  end

  def invalid_chess_move
    puts 'Invalid chess move.'
  end

  def invalid_castle
    puts 'Castling here is an invalid move'
  end

  def next_turn
    puts "-----------Chess-----------\n #{@player1} vs. #{@player2} |'H' for help\n"
  end

  def check(turn)
    turn ? puts("#{@player1}, you're in check!") : puts("#{@player2}, you're in check!")
  end

  def checkmate(turn)
    turn ? puts("#{@player2}, that's checkmate. You've won.") : puts("#{@player1}, that's checkmate. You've won.")
  end

  def new_game?
    puts "Type 'yes' if you wish to start a new game"
    answer = gets.chomp.downcase
    answer == 'yes'
  end

  def draw_offer(turn)
    if turn
      puts("#{@player1} wants a draw. Does #{@player2} accept?")
    else
      puts("#{@player2} wants a draw. Does #{@player1} accept?")
    end
    answer = gets.chomp.downcase
    answer == 'yes'
  end

  def drawn
    puts 'Game ends in a draw.'
  end

  def resigns(turn)
    turn ? puts("#{@player1} resigns. #{@player2} wins.") : puts("#{@player2} resigns. #{@player1} wins.")
  end

  def stalemate
    puts 'Game ends in a stalemate'
  end
end
