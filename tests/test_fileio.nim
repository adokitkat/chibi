import std/[asyncdispatch, asyncfile, os, strformat]

import chibi/fileio

let
  file_path = "tests/test_fileio.txt"
  str = "Hello, World!\nLorem Ipsum...\n\t~~~\t"
  str2 = "Uh oh"

var
  file: File
  aFile: AsyncFile
  aFileContent: string

proc prepareFile() =
  try:
    file = open(file_path, fmWrite)
    file.write(str)
  except IOError:
    quit fmt"Cannot open '{file_path}'"
  finally:
    file.close()
  assert readFile(file_path) == str

proc testRead(path, expected: string) {.async.} =
  aFile = openAsyncFileAt(path)
  aFileContent = await aFile.readAll()
  aFile.close()
  assert aFileContent == expected

proc testWrite(path, to_write: string) {.async.} =
  aFile = openAsyncFileAt(path, fmReadWrite)
  await aFile.write(to_write)
  aFile.setFilePos(0)
  aFileContent = await aFile.readAll()
  aFile.close()
  assert aFileContent == to_write

prepareFile()
waitFor testRead(file_path, str)
waitFor testWrite(file_path, str2)
prepareFile()

# Doesnt work on Windows
proc testAppend(path, to_append: string) {.async.} =
  aFile = openAsyncFileAt(path, fmAppend)
  await aFile.write(to_append)
  aFile.close()

waitFor testAppend(file_path, str2)
waitFor testRead(file_path, str & str2)

let x = loadAsyncFile(file_path)

when not defined(windows):
  assert x == str & str2

## END
removeFile(file_path)