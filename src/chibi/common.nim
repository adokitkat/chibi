## Add private variables or functions here that you don't want to export.
import std/times

type
  Content* = string

  IntermediateBuffer* = ref IntermediateBufferObj
  IntermediateBufferObj = object
    timeout: bool
    duration: DateTime
    content: Content

proc initIntermediateBuffer*(content: Content = "", timeout: bool = false,
                            duration: Duration = initDuration()): IntermediateBuffer = 
  result = new IntermediateBuffer
  result.content = content
  result.timeout = timeout
  result.duration = now() + duration

iterator countNatural*(): Natural {.closure.} =
  # Counts from 0 to 9223372036854775807
  # Before reaching it iterator resets back to 0
  var i = 0
  while i < int.high:
    yield i
    inc i
    if i == int.high-1: # No overflow pls
      i = 0
