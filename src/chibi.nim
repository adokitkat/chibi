## `chibi` text editor

#import std/[lists, ropes, streams, strformat, times, unicode]
import std/[os, terminal]

import chibi/textbuffer
import chibi/history
import chibi/fileio
import chibi/view

#[
type
  Editor* = object
    walls: seq[Wall]

  Wall* = ref WallObj
  WallObj = object
    file: File
    pos: Natural
    history: History
    historyLimit: Natural
]#

proc exitProc() {.noconv.} =
  deinitView()
  quit(0)

proc chibi() =

  setControlCHook(exitProc)

  var #wall = new Wall
    history = initHistory(3)
    textbuffer = initTextBuffer()
  
  initView()
  textbuffer.loadText("tests/test.txt")

  while true:
    textbuffer.display()
    sleep(200)
    terminal.setCursorPos(0, cursorPosEnd.y)
    echo "Cursor position: (", cursorPos.x, ", ", cursorPos.y, ")"

when isMainModule:
  chibi()