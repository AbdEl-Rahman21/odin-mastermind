# frozen_string_literal: true

require 'rainbow'

module Display
  def intro
    puts "\t\t == Open for business 2.0 =="
    puts "If you've never played Mastermind,"
    puts "it's a game where you have to guess your opponent's secret four digit code within a certain number of turns (like hangman with colored pegs)."
    puts 'Each turn you get some feedback about how good your guess was,'
    puts "whether it was exactly correct (\u25CF) or just the correct color but in the wrong space (\u25CB)."
  end

  def get_choice
    puts '1-Do you want to be a CodeBreaker.'
    puts '2-Or a CodeMaker.'

    loop do
      case choice = gets.chomp
      when '1'
        return 'breaker'
      when '2'
        return 'maker'
      else
        puts 'Invalid choice must be 1 or 2.'
      end
    end
  end

  def show_code(array)
    array.each do |digit|
      case digit
      when '1'
        print Rainbow("\s\s1\s\s").bg(:red)
      when '2'
        print Rainbow("\s\s2\s\s").bg(:green)
      when '3'
        print Rainbow("\s\s3\s\s").bg(:yellow)
      when '4'
        print Rainbow("\s\s4\s\s").bg(:blue)
      when '5'
        print Rainbow("\s\s5\s\s").bg(:magenta)
      when '6'
        print Rainbow("\s\s6\s\s").bg(:cyan)
      end
    end

    print "\s\s"
  end

  def show_clue(array)
    print 'Clue: '

    array.each do |clue|
      if clue
        print "\u25CF\s"
      elsif clue == false
        print "\u25CB\s"
      end
    end

    print "\n"
  end
end

class Game
  include Display

  attr_accessor :players, :code, :turn, :clues

  def initialize
    @code = []
    @clues = []
    @players = { code_breaker: '', code_maker: '' }
    @turn = 1
  end

  def play
    intro

    get_players

    p self.code = players[:code_maker].get_code

    loop do
      play_turn

      if clues.length == 4 && clues.all?(true)
        puts 'You Win!'

        break
      elsif turn > 12
        puts 'You Lose!'

        break
      end
    end
  end

  def get_players
    if get_choice == 'breaker'
      players[:code_breaker] = Human.new
      players[:code_maker] = Computer.new
    else
      players[:code_breaker] = Computer.new
      players[:code_maker] = Human.new
    end
  end

  def play_turn
    player = players[:code_breaker]

    puts "Round #{turn}"

    attempt = player.get_code

    show_code(attempt)

    show_clue(check_code(attempt))

    self.turn += 1
  end

  def check_code(attempt)
    self.clues = []

    code.each_with_index do |number, index|
      if attempt.include?(number)
        if attempt[index] == number
          clues.unshift(true)
        else
          clues.push(false)
        end
      end
    end

    clues
  end
end

class Human
  def get_code
    loop do
      print 'Enter code: '

      code = gets.chomp.split('')
      bad_code = false

      unless code.length == 4
        puts 'Error: Code must be four digits.'

        next
      end

      code.each_with_index do |number, _index|
        next if Array('1'..'6').include?(number)

        puts 'Error: Code must consist of numbers from 1 to 6.'

        bad_code = true

        break
      end

      return code unless bad_code
    end
  end
end

class Computer
  def get_code
    Array('1'..'6').sample(4, random: Random.new)
  end
end

Game.new.play
