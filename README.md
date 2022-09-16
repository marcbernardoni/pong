#[PONG](https://fr.wikipedia.org/wiki/Pong)

This is a small experiment to implement a version of the classic Pong game in an LUA

## Controls

arrow keys for the movement

## Simple AI

- The AI follows the ball's movements by moving automatically.
- To avoid playing "against a wall", the horizontal and vertical speeds of the ball are given randomly between -4 and 4.
- The speed of the ball also varies depending on where it hits the racket. It varies from 0% in the center to 10% on the ends.

## TODO

### Level 1

- Add sounds
- Add effects to the ball like drags

### Level 2

- Add random obstacles
- Make the pads break up little by little
- Add a start and end menu

### Level 3

- Improve the AI
