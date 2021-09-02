#import std/[lists, ropes, streams, strformat, times, unicode]

import chibi/history

type
  Editor* = object
    walls: seq[Wall]

  Wall* = ref WallObj
  WallObj = object
    file: File
    pos: Natural
    history: History
    historyLimit: Natural

proc chibi() =

  var
    #wall = new Wall
    history = initHistory(3)

  # For now...
  history.add("Hello, world!")
  history.add("Hello, Vim!")
  discard history.undo()
  history.add("Hello, Nim!")
  history.add("Hello, Zim?")
  discard history.undo()
  echo history
  echo history.getContent()
  discard history.redo()
  echo history
  echo history.getContent()

when isMainModule:
  chibi()