## File IO module for `chibi`

import std/[asyncdispatch, asyncfile, strformat]

#
# Synchronous IO
#

template withFile*(file: untyped, filename: string, mode: FileMode, body: untyped) =
  var file: File
  try:
    file = open(filename, mode)
    body
  except IOError as e: # Explicitly except
    quit(e.msg)
  finally:
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

#
# Async IO
#

proc loadFileAsync*(filename: string): Future[string] {.async.} =
  let
    file: AsyncFile = openAsync(filename, fmRead)
    future = file.readAll()
  yield future # Yields potentially unfinished Future[string]
  # Continiues here when `waitFor` or `await` is called
  file.close() # The Future is either finised or failed
  if future.finished:
    return future.read() # If finished return real value
  else:
    # TODO: Raise exception or show message that loading failed
    return ""