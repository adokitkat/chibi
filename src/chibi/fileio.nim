## File IO module for `chibi`

import std/[asyncdispatch, asyncfile, strformat]

proc openAsyncFileAt*(path: string,
                    filemode: FileMode = fmRead,
                    pos: Natural = 0): AsyncFile {.tags: [IOEffect, RootEffect].} =
  ## Use only FileModes fmRead, fmWrite & fmReadWriteExisting (maybe fmReadWrite?)
  ## fmAppend doesn't seem to work on Windows
  result = openAsync(path, filemode)
  result.setFilePos(pos)

proc loadAsyncFile*(path: string): string {.tags: [ReadIOEffect, IOEffect, TimeEffect, RootEffect].} =
  let file = openAsyncFileAt(path)
  result = waitFor file.readAll()
  file.close()

proc openFileAt*(path: string,
                filemode: FileMode = fmRead,
                pos: Natural = 0): File {.tags: [IOEffect], raises: [IOError].} =
  try:
    result = open(path, filemode)
    result.setFilePos(pos)
  except IOError as e:
    raise newException(IOError, e.msg)

proc loadFile*(path: string): string {.tags: [IOEffect, ReadIOEffect, WriteIOEffect]} =
  var file: File
  try:
    file = openFileAt(path)
    result = file.readAll()
  except IOError as e:
    stderr.write(fmt"Couldn't open the file '{path}'\n{e.msg}\n")
  finally:
    file.close()