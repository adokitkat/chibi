## Text buffer module for `chibi`

import std/[unicode]

#import fileio

# TODO: Paging?

type
  TextBuffer* = ref TextBufferObj
  TextBufferObj = object
    text*: ref seq[Rune]
    pos: Natural

  #TextCell = object
  #  value: Rune
    #bgColor: Color
    #fgColor: Color

proc initTextBuffer*(): TextBuffer =
  result = new TextBuffer
  result.pos = 0
  new result.text

proc loadData*(tb: var TextBuffer, data: string) =
  tb.text[] = data.toRunes()

#proc loadText*(tb: var TextBuffer, path: string) =
#  tb.text[] = fileio.loadFile(path).toRunes()

proc getText*(tb: TextBuffer): ref seq[Rune] = tb.text

proc write*(tb: TextBuffer, ch: char, pos: Natural) =
  tb.text[][pos] = ($ch).runeAt(0)