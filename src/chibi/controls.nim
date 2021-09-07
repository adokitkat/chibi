## Controls module for `chibi`
## 
## Inspiration: `illwill` package

import std/[posix, tables, terminal, unicode]

import textbuffer
import view

const KEY_SEQUENCE_MAX_LEN = 10
var
  keyBuf: array[KEY_SEQUENCE_MAX_LEN, int]
  insert*: bool = true

type Key* {.pure.} = enum
  None  = -1
  Up    = 1001
  Down  = 1002
  Right = 1003
  Left  = 1004

let keySequences = {
    Key.Up:    ["\eOA", "\e[A"],
    Key.Down:  ["\eOB", "\e[B"],
    Key.Right: ["\eOC", "\e[C"],
    Key.Left:  ["\eOD", "\e[D"]
  }.toTable

when defined(posix):

  proc kbhit(): cint = # TODO: What is going on...
    ## "Keyboard hit"
    var tv: Timeval
    tv.tv_sec = Time(0)
    tv.tv_usec = 0

    var fds: TFdSet
    FD_ZERO(fds)
    FD_SET(STDIN_FILENO, fds)
    discard select(STDIN_FILENO+1, fds.addr, nil, nil, tv.addr)
    return FD_ISSET(STDIN_FILENO, fds)

  proc getKey*(): Key =
    var chars_read = 0
    while kbhit() > 0 and chars_read < KEY_SEQUENCE_MAX_LEN:
      var ret = posix.read(0, keyBuf[chars_read].addr, 1)
      if ret > 0:
        chars_read += 1
      else:
        break

    var key = Key.None
    if chars_read == 0:  # nothing read
      return Key.None

    elif chars_read == 1:
      return keyBuf[0].Key

    else:
      var inputSeq = ""
      for i in 0..<chars_read:
        inputSeq &= char(keyBuf[i])
      for keyCode, sequences in keySequences.pairs:
        for s in sequences:
          if s == inputSeq:
            key = keyCode.Key
    result = key

when defined(windows):
  proc kbhit(): cint {.importc: "_kbhit", header: "<conio.h>".}
  # TODO

proc to1D(t: tuple[x, y: int]): Natural = 
  # TODO: 
  result = t.x.Natural

proc control*(tb: TextBuffer): bool =
  result = false
  
  var key = getKey()

  if key != Key.None:
    view.scene.cursorPos = getCursorPos()
    case key:
      of Up: terminal.cursorUp()
      of Down: terminal.cursorDown()
      of Right: terminal.cursorForward()
      of Left: terminal.cursorBackward()
      else:
        #stdout.write char(key) # TODO: chr() is safer
        if insert:
          tb.text[].insert(($char(key)).runeAt(0), view.getCursorPos().to1D())
        else: # Overwrite
          tb.write(char(key), view.getCursorPos().to1D())
        result = true
    stdout.flushFile()
