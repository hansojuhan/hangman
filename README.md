# Hangman
Features:
- Uses the google-10000-english-no-swears.txt dictionary file as source.
- When a new game is started, game loads in the dictionary and randomly select a word between 5 and 12 characters long for the secret word.
- Every turn, allow the player to make a guess of a letter. It should be case insensitive. Update the display to reflect whether the letter was correct or incorrect. If out of guesses, the player should lose.

- Now implement the functionality where, at the start of any turn, instead of making a guess the player should also have the option to save the game. Remember what you learned about serializing objects… you can serialize your game class too!
- When the program first loads, add in an option that allows you to open one of your saved games, which should jump you exactly back to where you were when you saved. Play on!
