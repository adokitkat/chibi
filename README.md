# Chibi

Cute little modular text editor written in Nim

Work in progress...

## Goals

- Write my own terminal based text editor
- Modular design, easy to modify & extend
- Use only `stdlib`, no dependecies unless necesarry
- Get better at [Nim programming language](https://nim-lang.org/) along the way

### Long-term goals

- Windows compatibility / Cross-platform portability (Currently tested only on Linux)
- Hot code reloading / embed Nim interpreter to change program on the fly
- Mouse support
- Write a tutorial / blog post about this?

## Features

### Done

- Terminal fullscreen view
- File loading
- Displaying the text buffer
- Controls (arrows, ...)
- Catching signals: interrupt (`SIGINT`), pause (`SIGTSTP`), resize (`SIGWINCH`)

### In progress

- History saving

### TODO

- Everything else
- Refactoring...

## Resources

- [`illwill` package](https://github.com/johnnovak/illwill) - inspiration
