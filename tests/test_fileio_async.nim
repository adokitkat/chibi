import asyncdispatch, os
import chibi/fileio

const
    path = "tests/text_fileio_async.txt"
    data = "abc123"

# Prepare
withFile(f, path, fmWrite):
  f.write("A") # Create file

var a: string
withFile(f, path, fmRead):
  a = f.readAll()
assert a == "A" #

# Test
let read_future = readFileAsync(path)
let test1 = waitFor read_future
assert test1 == a

let write_future = writeFileAsync(path, data)
let test2 = waitFor write_future
assert test2 == true

var data_compare: string
withFile(f, path, fmRead):
  data_compare = f.readAll()
assert data_compare == data

# Finish
removeFile(path)