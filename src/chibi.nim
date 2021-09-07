## `chibi` text editor
## 
## Author: Adam Múdry

#import std/[lists, ropes, streams, strformat, times, unicode]
import std/[asyncdispatch, os]

import chibi/controls
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

  let text_future: Future[string] = loadFileAsync("tests/test2.txt") # Asynchronously load text

  var #wall = new Wall
    #history = initHistory(3)
    textbuffer = initTextBuffer()
    change: bool = false
  
  initView()
  textbuffer.loadData(waitFor text_future) # Async text load finish
  view.display(textbuffer)
  while true:
    change = controls.control(textbuffer)
    #view.showCursorPos()
    if change:
      view.display(textbuffer)
    view.checkTerminalResize(textbuffer)
    sleep(10)

when isMainModule:
  chibi()