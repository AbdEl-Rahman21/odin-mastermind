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
    puts 'Enter 1 or 2'

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

  def initialize
    @code = []
    @clues = []
    @players = { code_breaker: '', code_maker: '' }
    @turn = 1
  end

  def play
    system('clear')

    intro

    get_players

    self.code = players[:code_maker].get_code

    loop do
      play_turn

      if clues.count(true) == 4
        if players[:code_breaker].instance_of?(Human)
          puts 'You Win!'
        else
          puts 'You Lose!'
        end

        break
      elsif turn > 12
        if players[:code_breaker].instance_of?(Human)
          puts 'You Lose!'
          print 'The code is: '

          show_code(code)

          print "\n"
        else
          puts 'You Win!'
        end

        break
      end
    end

    repeat
  end

  private

  attr_accessor :players, :code, :turn, :clues

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

    attempt = if player.instance_of?(Human)
                player.get_code
              else
                player.break_code(clues, turn)
              end

    show_code(attempt)

    show_clue(check_code(attempt))

    self.turn += 1
  end

  def check_code(attempt)
    self.clues = []
    code_test = code.dup

    attempt.each_with_index do |number, index|
      next unless code_test.include?(number)

      if number == code_test[index]
        clues.unshift(true)
      else
        clues.push(false)
      end

      code_test[code_test.index(number)] = '0'
    end

    clues
  end

  def repeat
    loop do
      print 'Do you want to play again (Y\\N): '

      case gets.chomp.downcase
      when 'y'
        Game.new.play
      when 'n'
        return nil
      else
        puts 'Error: Invalid Input'
      end
    end
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
  attr_accessor :code_set, :guess

  def initialize
    @code_set = []

    generate_all_code

    @guess = []
  end

  def get_code
    code_set.sample.flatten
  end

  def generate_all_code
    123_456
      .to_s
      .split('')
      .repeated_permutation(4) { |comb| code_set.push(comb) }
  end

  def break_code(clues, turn)
    temp = []

    return self.guess = code_set[0] if turn == 1

    if clues.length != 4
      temp = guess
      self.guess = code_set[code_set.index(guess) + 259]

      clues.length.times { |i| guess[i] = temp[i] }
    else
      code_set.delete(guess)

      code_set.filter! do |code|
        good_code = true
        counter = 0
        temp = guess.dup

        code.each do |number|
          if temp.include?(number)
            counter += 1
            temp.delete_at(temp.index(number))
          end
        end

        good_code = false if counter != 4

        good_code
      end

      if clues.count(true).positive?
        code_set.filter! do |code|
          good_code = true
          counter = 0

          guess.each_with_index do |number, index|
            counter += 1 if code.include?(number) && number == code[index]
          end

          good_code = false if counter < clues.count(true)

          good_code
        end
      end

      self.guess = code_set[0]
    end

    guess
  end
end

Game.new.play
