Play a series of games against the AI or another player using the command line. You can save and reload during any games.

# Mastermind
![AI guessing code in traditional board size](screen_recordings/mastermind_ai_guessing.gif)
- Guess the secret code and get feedback: correct colours in the right place, and correct colours in the wrong place.
- Play with up to 8 colours and 8 holes.
## 1-Player mode
- Guess a code randomly chosen by the computer.
- Choose a code for the AI to guess with its optmal* strategy.
## 2-Player mode
- Enter your code in secret; the computer will give your opponent feedback
- Guess your opponent's secret code
*Minimizes worst case number of guesses (eg always guesses a 4-hole, 6-colour code in 5 guesses)

# Hangman
## 1-Player mode
- Guess a word randomly chosen from the computer's dictionary
- Choose a word for the AI to guess; give feedback on its guesses
## 2-Player mode
- Enter your word in secret; the computer will give your opponent feedback
- Guess your opponent's secret word

# Tic-Tac-Toe
## 1-Player mode
- Plays tic-tac-toe (noughts and crosses) optimally*. It will not lose, and it punishes mistakes.
## 2-Player mode
- PvP mode alse available
*Maximizes the chance of winning via a fork, and secondarily by winning through a mistake.

# Nim
- Choose the number of lines in each game, or let the computer choose them randomly.
## 1-Player mode
- Plays nim optimally. Always wins if given a board with nimsum zero and prolongs games in losing positions.
## 2-Player mode
- PvP mode also available
