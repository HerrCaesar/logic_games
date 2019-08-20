Play a series of games against the AI or another player using the command line. You can save and reload during any games.

# Mastermind
![AI guessing code in Mastermind (traditional board size)](screen_recordings/mastermind_ai_guessing.gif)
- Guess the secret code and get feedback: correct colours in the right place, and correct colours in the wrong place.
- Play with up to 8 colours and 8 holes.
## 1-Player mode
- Guess a code randomly chosen by the computer.
- Choose a code for the AI to guess with its optmal strategy.
- AI minimizes worst case number of guesses needed (eg always guesses a 4-hole, 6-colour code in 5 guesses).
- Each turn the AI uses each code (including impossible ones) to partition the codes still possible into groups. Each code in a group would respond in the same way if they were correct and the partitioning code was guessed. The AI then compares the largest groups under each partitioning code and chooses the partitioning code that creates the smallest maximum group. (In a case of a tie, possible codes are preferred, then the smallest next-to-maximum group, etc.)
## 2-Player mode
- Enter your code in secret; the computer will give your opponent feedback
- Guess your opponent's secret code

# Hangman
![AI guessing secret word (ruby) in Hangman](screen_recordings/hangman_ai_guessing.gif)
## 1-Player mode
- Guess a word randomly chosen from the computer's dictionary
- Choose a word for the AI to guess; give feedback on its guesses. AI will guess the letter that occurs in most dictionary that could still be the secret code. If your word isn't in its dictionary, it guesses by sheer letter frequency.
## 2-Player mode
- Enter your word in secret; the computer will give your opponent feedback
- Guess your opponent's secret word

# Tic-Tac-Toe
![AI playing series of tic-tac-toe games](screen_recordings/tic_tac_toe_vs_ai.gif)
## 1-Player mode
- Plays tic-tac-toe (noughts and crosses) optimally. It will not lose, and it punishes mistakes.
- AI conostructs a trie of game states under starting position and each turn chooses the branch that maximizes the number of moves ahead it opponent needs to think, and secondarily the opportunities for opponent mistakes.
## 2-Player mode
- PvP mode alse available

# Nim
![AI playing series of nim games](screen_recordings/nim_vs_ai.gif)
- Players take it in turns to take as many objects they like - as long as they're from the same line (heap)
- The player who takes the last object loses
- Choose the number of heaps in each game, or let the computer choose them randomly
## 1-Player mode
- AI plays nim optimally. Always wins as quickly as possible unless the nimsum is zero, in which case it prolongs the game as much as possible
## 2-Player mode
- PvP mode also available

# Chess
![Fool's mate, followed by fast stalemate](screen_recordings/chess_fools_mate_stalemate.gif)
- Specify moves using flexibly interpreted [agebraic notation](https://en.wikipedia.org/wiki/Algebraic_notation_(chess))
- All [FIDE rules of play](https://www.fide.com/FIDE/handbook/LawsOfChess.pdf) are implemented except draw by repition or 50 moves without capture or movement of a pawn
## Only 2-player mode available