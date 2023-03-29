# frozen_string_literal: true

require 'rainbow'

module Display
  def intro
    puts "\t\t == Open for business 2.0 =="
    puts "If you've never played Mastermind,"
    print "it's a game where you have to guess your opponent's secret four digit code within a certain number of turns "
    puts '(like hangman with colored pegs).'
    puts 'Each turn you get some feedback about how good your guess was,'
    puts "whether it was exactly correct (\u25CF) or just the correct color but in the wrong space (\u25CB)."
  end

  def get_choice
    puts '1-Do you want to be a CodeBreaker.'
    puts '2-Or a CodeMaker.'
    puts 'Enter 1 or 2'

    loop do
      case gets.chomp
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

  def handle_win(breaker)
    if breaker.instance_of?(Human)
      puts 'You Win!'
    else
      puts 'You Lose!'
    end
  end

  def handle_lose(breaker, code)
    if breaker.instance_of?(Human)
      puts 'You Lose!'
      print 'The code is: '

      show_code(code)

      print "\n"
    else
      puts 'You Win!'
    end
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

  def create_game
    system('clear')

    intro

    get_players

    self.code = players[:code_maker].get_code

    play

    repeat
  end

  private

  attr_accessor :players, :code, :turn, :clues

  def play
    loop do
      play_turn

      if clues.count(true) == 4
        handle_win(players[:code_breaker])

        break
      elsif turn > 12
        handle_lose(players[:code_breaker], code)

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

    attempt =
      if player.instance_of?(Human)
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

      add_clue(number, code_test[index])

      code_test[code_test.index(number)] = '0'
    end

    clues
  end

  def add_clue(number1, number2)
    if number1 == number2
      clues.unshift(true)
    else
      clues.push(false)
    end
  end

  def repeat
    loop do
      print 'Do you want to play again (Y\\N): '

      case gets.chomp.downcase
      when 'y'
        Game.new.create_game
      when 'n'
        exit
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

      return code unless valid?(code)
    end
  end

  private

  def valid?(code)
    bad_code = false

    code.each_with_index do |number, _index|
      next if Array('1'..'6').include?(number) && code.length == 4

      puts 'Error: Code must consist of four digits from 1 to 6.'

      bad_code = true

      break
    end

    bad_code
  end
end

class Computer
  def initialize
    @code_set = []

    generate_all_code

    @guess = []
  end

  def get_code
    code_set.sample.flatten
  end

  def break_code(clues, turn)
    return self.guess = code_set[7] if turn == 1

    code_set.delete(guess)

    if clues.empty?
      filter_no_clues
    else
      filter_false_clues(clues)

      filter_true_clues(clues) if clues.count(true).positive?
    end

    self.guess = code_set.sample
  end

  private

  attr_accessor :code_set, :guess

  def generate_all_code
    123_456
      .to_s
      .split('')
      .repeated_permutation(4) { |comb| code_set.push(comb) }
  end

  def filter_no_clues
    code_set.filter! do |code|
      good_code = true

      code.each do |number|
        next unless guess.include?(number)

        good_code = false

        break
      end

      good_code
    end
  end

  def filter_false_clues(clues)
    code_set.filter! do |code|
      good_code = true

      good_code = false if filter_single_code(code) != clues.length

      good_code
    end
  end

  def filter_single_code(code)
    counter = 0
    temp = guess.dup

    code.each do |number|
      if temp.include?(number)
        counter += 1
        temp.delete_at(temp.index(number))
      end
    end

    counter
  end

  def filter_true_clues(clues)
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
end

Game.new.create_game
