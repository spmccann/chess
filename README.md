# 🄲🄷🄴🅂🅂  
![chessproject](/images/newgame.png)
# Core Features

### All Chess Rules Implemented
- Piece move rules
- Checkmate
- Stalemate
- Draws
- En Passant
- Castling short and long

### Game Modes
- 2-Players
- Player vs Computer
- Computer vs Computer
![comvscom](/images/com-vs-com-cm.png)

### Menu Options
- Game data can be saved to JSON file and loaded from file
- Help menu and in-game options for draw offer, resign and quit
![comvscom](/images/helpmenu.png)

# Classes and Files
- game.rb - procedural execute game loop from start to end. Main game file. 

- Moves (moves.rb) - contains the rules for all pieces and evaluating games state/objectives.

- Messages (messages.rb) - Communicates with the player about their turn and board conditions.

- Notation (notation.rb) - Allows for board state to be converted between arrays of algebraic, index and cordinates elements to better cohearse game logic.

- Pieces (pieces.rb) - Stores the Unicode characters for the chess board.

- Coordinates (cords_module.rb) - module for the movement path constants for each piece.

- Serilize (serialize.rb) - Loading and Saving to file. Creating the directory and file.

- Board (board.rb) - Generating the terminal chess board visuals.


 