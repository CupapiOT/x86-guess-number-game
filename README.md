# Guess The Number in x86 NASM

A simple game made to learn how to handle user input in Assembly code.

https://github.com/user-attachments/assets/eda9b820-d3bf-40cc-9748-8249eef3e18c

## Features

- **Core Features**
  - Lets the user guess a number between 1 and `MAX` (set in the program).
  - Tells the player whether they've guess too high or too low.
  - Tells the player how many guesses it took when they get it right.

- **Retry**
  - Upon winning, it asks the user if they want to try again.
  - Input anything other than `y`/`n` and it won't respond.
  - Input `y` and it jumps to the start of the program.
  - Input `n` and it exits.

- **Error Handling**
  - Inputting numbers less than 1 or greater than `MAX` prints "Please enter a
    number from 1 to `MAX`."
  - Inputting non-numbers prints the same thing.
  - Inputting anything greater than the number of digits `MAX` does so as well.

## Stack

- x86 Assembly (Netwide Assembler syntax)
- GDB for debugging
- C stdlib functions for printing and generating a random number

## Footnotes

- This was made as part of a small coding challenge on a Discord server,
  completed in around 7 hours.
- This game was originally made on the 14th of April 2026 but was not uploaded
  until 6th of June 2026 to GitHub.
