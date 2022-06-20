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
    puts "Hello #{@player1} and #{@player2}. White goes first. It's #{@player1}'s turn."
  end

  def move
    puts 'Enter a move.'
  end
end
