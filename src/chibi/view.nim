## View module for `chibi`
## 
## Inspiration: `illwill` package

import std/[os, posix, strutils, termios, terminal, unicode]

import textbuffer
import controls

proc initView*()
proc deinitView*()
proc reinitView()
#proc redraw()

type
  # TODO: Maybe plain `object` insted of `ref object`? It's a small structure.
  #View* = ref ViewObj
  View* = object
    cursorPos*, cursorPosFileEnd*: tuple[x, y: int]
    terminalSize*: tuple[w, h: int]
    resized*: bool

var
  scene*: View

when defined(posix):
  proc sigtstpHandler(sig: cint) {.noconv.} =
    ## Ctrl + Z => process to background
    signal(SIGTSTP, SIG_DFL) # Disconnects signal handler
    # TODO: make this work properly
    deinitView()
    discard posix.raise(SIGTSTP)

  proc sigcontHandler(sig: cint) {.noconv.} =
    ## $ fg => process to foreground
    signal(SIGCONT, sigcontHandler)
    signal(SIGTSTP, sigtstpHandler) # Reconnects signal handlers
    reinitView()
  
  proc sigwinchHandler(sig: cint) {.noconv.} =
    ## Terminal window reize signal (28 on x86/ARM)
    scene.terminalSize = terminal.terminalSize()
    scene.resized = true

  proc initSignalHandlers() =
    signal(SIGCONT, sigcontHandler)
    signal(SIGTSTP, sigtstpHandler)
    signal(cint(28), sigwinchHandler) # SIGWINCH

  proc nonblock(enabled: bool) =
    var ttyState: Termios
    # get the terminal state
    discard tcGetAttr(STDIN_FILENO, ttyState.addr)

    if enabled:
      # turn off canonical mode & echo
      ttyState.c_lflag = ttyState.c_lflag and not Cflag(ICANON or ECHO)
      # minimum of number input read
      ttyState.c_cc[VMIN] = 0.cuchar
    else:
      # turn on canonical mode & echo
      ttyState.c_lflag = ttyState.c_lflag or ICANON or ECHO

    # set the terminal attributes.
    discard tcSetAttr(STDIN_FILENO, TCSANOW, ttyState.addr)

when defined(posix):
  type TermEnv {.pure.} = enum
    XtermColor = "xterm-color"
    Xterm256Color = "xterm-256color"

  proc enterFullScreen() =
    ## Enters full-screen mode (clears the terminal).
    case getEnv("TERM"):
    of $XtermColor:
      stdout.write "\e7\e[?47h"
    of $Xterm256Color:
      stdout.write "\e[?1049h"
    else:
      eraseScreen()

  proc exitFullScreen() =
    ## Exits full-screen mode (restores the previous contents of the terminal).
    case getEnv("TERM"):
    of $XtermColor:
      stdout.write "\e[2J\e[?47l\e8"
    of $Xterm256Color:
      stdout.write "\e[?1049l"
    else:
      eraseScreen()

  proc getCursorPos*(): tuple[x, y: int] =
    ## Request cursor position with `\e[6n"`.
    ## 
    ## Get response like `\e[y;xR` where `y` and `x` are coordinates.
    if terminal.isatty(stdout):
      stdout.write("\e[6n")
      var
        x, y: string
        next: bool = false
        ch: char
      while ch != 'R':
        ch = getch()
        if ch == ';':
          next = true
        if ch in '0'..'9':
          if not next:
            y.add(ch)
          else:
            x.add(ch)
      return (parseInt(x), parseInt(y))

when defined(windows):
  {.fatal: "Not implemented view module for Windows".}
  proc enterFullScreen()
  proc exitFullScreen()

proc display*(tb: TextBuffer) =
  terminal.setCursorPos(0,0)
  terminal.eraseScreen()
  stdout.write($(tb.getText()[]))
  scene.cursorPosFileEnd = getCursorPos()
  terminal.setCursorPos(scene.cursorPos.x-1, scene.cursorPos.y-1)
  stdout.flushFile()

proc showCursorPos*() =
  let pos = getCursorPos()
  terminal.setCursorPos(0, scene.terminalSize.h-1)
  stdout.write("Cursor position: (", scene.cursorPos.x, ", ", scene.cursorPos.y, ")")
  stdout.flushFile()
  terminal.setCursorPos(pos.x, pos.y)

proc checkTerminalResize*(tb: TextBuffer) =
  if scene.resized:
    tb.display()
    #showCursorPos()
    scene.resized = false

proc reinitView() =
  ## initView() without initSignalHandlers()
  nonblock(true)
  enterFullScreen()
  resetAttributes()
  #hideCursor() # I would like to see where I am pointing
  terminal.setCursorPos(0,0)

proc initView*() =
  ## Initializes view module
  ## 
  ## Use before anything else in this module
  
  #new view
  scene = View(cursorPos: (0, 0),
              cursorPosFileEnd: (0, 0),
              terminalSize: terminal.terminalSize(),
              resized: false)
  initSignalHandlers()
  reinitView()

proc deinitView*() =
  ## Deinitializes view module
  ##
  ## Use when quitting program with `Ctrl+C` like:
  ## 
  ## .. code:: nim
  ## 
  ##   proc exitProc() {.noconv.} =
  ##     deinitView()
  ##     quit(0)
  ## 
  ##   setControlCHook(exitProc)
  
  nonblock(false)
  exitFullScreen()
  terminal.resetAttributes()
  terminal.showCursor()

when isMainModule:
  proc exitProc() {.noconv.} =
    deinitView()
    quit(0)

  setControlCHook(exitProc)
  initView()
  
  echo "START"
  var i = 0
  while true:
    sleep(500)
    stdout.write($i & "\n")
    stdout.flushFile
    inc i