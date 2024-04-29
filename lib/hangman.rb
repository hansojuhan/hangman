require 'pry-byebug'
require 'yaml'

class Hangman
  attr_accessor :last_guess, :remaining_guesses
  attr_reader :secret_word, :guessed_word

  # All allowed letters for checking the input
  ALPHABET = "abcdefghijklmnopqrstuvwxyz"
  # Savegame path
  SAVE_PATH = Dir.pwd + '/saves'

  def initialize
    # Total amount player can guess wrong
    @remaining_guesses = 6

    # Goal word
    # Currently guessed word
    @secret_word, @guessed_word = initialize_words

    # Last guess
    @last_guess = ""
  end

  def print_intro_screen
    print `clear` << "Welcome to Hangman!\n---\nCreated by hje\nApril 2024\n\n(N) New game\t\t(L) Load game\t\t(Q) Quit\n\nChoose: "
  end

  def main_menu
    
    loop do
      
      # Ask user to load game, if they wish
      print_intro_screen

      # Get choice
      choice = gets.chomp
      choice = choice.downcase

      # Make actions based on choice
      if ["q","quit","quit game"].include?(choice)
        
        print `clear`
        puts "Ciao!"
        exit(true)
        
      elsif ["l","load","load game"].include?(choice)

        load_game
        return

      elsif ["n","new","new game"].include?(choice)

        return

      end
    end
  end

  def start

    #Start with main menu
    main_menu

    # Game loop
    # Render out the word, with amount of letters
    # Allow user to guess a letter
    # Parse input, which has to be a letter
    # Go through the word, check for matches, if match, fill in the word
    # Game ends when out of turns or guessed the word
    while !game_over? do
      render_game
  
      puts "Tries left: #{remaining_guesses}"
  
      input = get_input
      # Let the user guess
      if input == "save"
        # Save the game
        save_game

        # Finish game
        game_over = true
      else
        self.last_guess = input
      end

      # Check the word with the guess
      # If no match was found, decrease remaining guesses
      compare_word_with_input

      if game_over?
        if game_won?
          render_game
          puts "\n\nWord was: #{secret_word}! You won!"
        else
          puts "Too bad, you hanged the man!"
        end
      end
    end
  end

  # private

  # Get a name and check it doesn't exist
  def find_valid_save_filename(path)
    name_valid = false
    until name_valid

      name = gets.chomp
      name = name << ".hangman"

      if File.exist?("#{SAVE_PATH}/#{name}")
        print "Save already exists, choose another name: "
      else
        return name
      end 
    end
  end

  # Files the class state to file as yaml
  def save_game_to_file(filename)
    begin
      file = File.open("#{SAVE_PATH}/#{filename}", "w")
      file.write(class_to_yaml)
    rescue IOError => e
      # Errors?
    ensure
      file.close
    end
  end

  def save_game
    # To save game, need to 
    # 1) Get a savegame name
    # 2) Check in the folder if such file exists
    # 3) If folder does not exist, create that
    # 4) Then save file
    # 5) Saving file is dumping the class into yaml

    # First, check folder exists. If not, make it
    Dir.mkdir("saves") unless Dir.exist?(SAVE_PATH) 

    print "\nEnter a name for the save: "
    name = find_valid_save_filename(SAVE_PATH)
    
    # Open and write that into the file
    save_game_to_file(name)

    # Go back to the beginning
    puts "Game saved as '#{name}'. Press any key to go to main menu."
    gets
    start
  end

  def list_saved_games
    puts "\nYour saved games:"
    Dir.foreach("#{SAVE_PATH}") do |savefile|
      puts savefile.chomp(".hangman") if savefile.include?(".hangman")
    end
  end

  def select_saved_game
    name_valid = false
    until name_valid

      name = gets.chomp
      name = name << ".hangman"

      if File.exist?("#{SAVE_PATH}/#{name}")
        return name
      else
        print `clear`
        print "Save does not exist"
        list_saved_games
      end 
    end
  end


  def load_game
    # List all savefiles in the save directory
    list_saved_games

    # Select a save
    name = select_saved_game

    # Read same file
    begin
      file = File.open("#{SAVE_PATH}/#{name}", "r")
      lines = File.read(file)

      # Safe load the data, permetting the Hangman class only
      data = YAML.safe_load(lines, permitted_classes: [Hangman])
    rescue IOError => e
      # Errors
    ensure
      file.close
    end

    # Update the instance variables to load the game
    self.update_game_state(data)
  end

  # Create the yaml dump of the class
  def class_to_yaml
    YAML.dump (self)
  end

  def update_game_state(data)
    # Open and write that into the file
    @remaining_guesses = data.remaining_guesses
    @secret_word = data.secret_word
    @guessed_word = data.guessed_word
    @last_guess = data.last_guess
  end

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

  # Parses the input and returns it according to the rules
  # If input is "save", returns "save" to start saving the game
  def get_input
    input_received = false

    while !input_received do

      print "Guess a letter:\t"
      input = gets.chomp.downcase
      
      # Input has to be one letter
      if input == "save"
        return "save"
      elsif input.length == 1 && ALPHABET.include?(input)
        return input
        input_received = true
      else
        puts "You must guess a letter!"
      end

    end
  end

  def render_game
    # Wow, this way you can clear the console
    print `clear`

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
# # game.load_game
# game.save_game
