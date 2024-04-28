
# Start game (initialise all the variables, such as
# - Turns
# - Word to be guessed
# - Current turn)
require 'pry-byebug'

class Hangman
  attr_accessor :last_guess, :remaining_guesses
  attr_reader :secret_word, :guessed_word

  # All allowed letters for checking the input
  ALPHABET = "abcdefghijklmnopqrstuvwxyz"

  def initialize
    # Total amount player can guess wrong
    @remaining_guesses = 6

    # Goal word
    # Currently guessed word
    @secret_word, @guessed_word = initialize_words

    # Last guess
    @last_guess = ""
  end

  def start
    # Game loop
    # Render out the word, with amount of letters
    # Allow user to guess a letter
    # Parse input, which has to be a letter
    # Go through the word, check for matches, if match, fill in the word
    # Game ends when out of turns or guessed the word
    while !game_over? do
      render_game
  
      puts "Tries left: #{remaining_guesses}"
  
      # Let the user guess
      get_input
  
      # Check the word with the guess
      # If no match was found, decrease remaining guesses
      compare_word_with_input

      if game_over?
        if game_won?
          puts "Word was: #{secret_word}! Game over!"
        else
          puts "Too bad, you hanged the man!"
        end
      end
    end
  end

  private

  def game_over?
    remaining_guesses == 0 || guessed_word.include?("_") == false
  end

  def game_won?
    guessed_word.include?("_") == false
  end

  def compare_word_with_input
    # Go through the secret word as an array
    # For each position of the array, if the letter matches, 
    # update the guessed word

    # Keep track of whether match was found
    match_found = false
    
    secret_word.split("").each_with_index do |letter,index|
      if letter == last_guess
        guessed_word[index] = last_guess

        match_found = true
      end
    end

    # If no match was found, decrease remaining guesses
    if match_found == false 
      self.remaining_guesses -= 1
    end
  end

  def get_input
    input_received = false

    while !input_received do

      print "Guess a letter:\t"
      input = gets.chomp.downcase
      
      # Input has to be one letter
      if input.length == 1 && ALPHABET.include?(input)
        self.last_guess = input
        input_received = true
      else
        puts "You must guess a letter!"
      end

    end
  end

  def render_game
    puts " "
    puts "Guess the word:\t\t#{guessed_word.split("").join(" ")}"
  end

  def initialize_words
    # Read all lines into an array and remove the newlines with chomp
    # On that array, use map to get the sub-array of words between 7-12 in length
    # With sample, get one of those at random
    all_words = File.readlines('words.txt', chomp: true)
    valid_words = all_words.select { |word| word if word.length.between?(7,12) }

    secret = valid_words.sample
    guess = "_" * secret.length

    return secret, guess
  end
end

game = Hangman.new
game.start
