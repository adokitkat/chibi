import std/[asyncdispatch, asyncfile, os, strformat]

import chibi/fileio

let
  path = "tests/test_fileio.txt"
  str = "Hello, World!\nLorem Ipsum...\n\t~~~\t"
  str2 = "Uh oh"
var
  file: File
  aFile: AsyncFile
  aFileContent: string

proc prepareFile() =
  try:
    file = open(path, fmWrite)
    file.write(str)
  except IOError:
    quit fmt"Cannot open '{path}'"
  finally:
    file.close()
  assert readFile(path) == str

proc testRead(expected: string) {.async.} =
  aFile = openAsyncFileAt(path)
  aFileContent = await aFile.readAll()
  aFile.close()
  assert aFileContent == expected

proc testWrite(to_write: string) {.async.} =
  aFile = openAsyncFileAt(path, fmReadWrite)
  await aFile.write(to_write)
  aFile.setFilePos(0)
  aFileContent = await aFile.readAll()
  aFile.close()
  assert aFileContent == to_write

prepareFile()
waitFor testRead(str)
waitFor testWrite(str2)
prepareFile()

# Doesn't work?
proc testAppend(to_append: string) {.async.} =
  aFile = openAsyncFileAt(path, fmAppend)
  await aFile.write(to_append)
  aFile.close()

#waitFor testAppend(str2)
#waitFor testRead(str & str2)

let x = loadAsyncFile(path)
echo x
echo "abc"

## END
#removeFile(path)