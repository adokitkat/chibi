import std/[asyncdispatch, asyncfile]

proc openAsyncFileAt*(path: string, filemode: FileMode = fmRead, pos: Natural = 0): AsyncFile =
  ## Use only FileModes fmRead, fmWrite & fmReadWriteExisting (maybe fmReadWrite?)
  ## fmAppend doesn't seem to work on Windows
  result = openAsync(path, filemode)
  result.setFilePos(pos)

proc loadAsyncFile*(path: string): string =
  let file = openAsyncFileAt(path)
  result = waitFor file.readAll()
  file.close()

proc openFileAt*(path: string, filemode: FileMode = fmRead, pos: Natural = 0): File =
  try:
    result = open(path, filemode)
    result.setFilePos(pos)
  except IOError:
    result = nil


