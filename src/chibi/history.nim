import std/[strformat, times]

import common

type
  History* = ref HistoryObj
  HistoryObj = object
    first, last, active: HistoryBuffer
    limit, len, undo_count: Natural
    id_iterator: iterator(): Natural

  HistoryBuffer* = ref HistoryBufferObj
  HistoryBufferObj {.acyclic.} = object
    prev, next: HistoryBuffer
    id: Natural
    timestamp: DateTime
    content: Content

  HistoryContent* = tuple[pos: Natural, str: string] # TODO:

proc initHistoryBuffer(id: Natural,
                      prev: HistoryBuffer = nil,
                      next: HistoryBuffer = nil,
                      timestamp: DateTime = now(),
                      content: Content = "") : HistoryBuffer =
  result = new HistoryBuffer
  result.id = id
  result.prev = prev
  result.next = next
  result.timestamp = timestamp
  result.content = content

# TODO: do something better for $ operator
proc `$`*(hb: HistoryBuffer): string = "[" & $hb.id & "] " & hb.timestamp.format("fffffffff")
proc `$`*(h: History): string = fmt"F={h.first.id} L={h.last.id} A={h.active.id} len={h.len}"

proc printFromFirst*(h: History) =
  var it {.cursor.}: HistoryBuffer = h.first
  while it != nil:
    stdout.write(fmt"{it} ")
    it = it.next

proc initHistory*(limit: Natural = 0): History =
  result = new History
  result.id_iterator = countNatural
  result.limit = limit
  result.len = 1
  result.undo_count = 0
  result.active = initHistoryBuffer(id=result.id_iterator())
  result.first = result.active
  result.last = result.active

proc popFirst(h: var History): bool =
  # popFirst() is called by append() if history length out of range
  # Returns true if popped, false if didn't
  if h.len > 1:
    dec h.len
    h.first = h.first.next
    if h.first.prev != nil:
      h.first.prev = nil
    return true
  return false

proc append*(h: var History): HistoryBuffer =
  # Appends new HistoryBuffer after current active HistoryBuffer
  # Existing HistoryBuffers after active one are discarted
  # The new HistoryBuffer is then set as active one
  if h.active.next != nil:
    h.active.next.prev = nil
  
  result = initHistoryBuffer(id=h.id_iterator(), prev=h.active)
  h.active.next = result

  h.len = h.len + 1 - h.undo_count
  h.undo_count = 0
  h.active = h.active.next
  h.last = h.active

  if h.limit > 0:
    if h.len > h.limit:
      discard h.popFirst()

proc undo*(h: var History): bool =
  # Active HistoryBuffer is set to previous one if possible
  if h.active.prev != nil:
    h.active = h.active.prev
    inc h.undo_count
    return true
  return false

proc redo*(h: var History): bool =
  # Active HistoryBuffer is set to next one if possible
  if h.active.next != nil:
    h.active = h.active.next
    dec h.undo_count
    return true
  return false

proc add*(h: var History, content: Content) =
  # Adds content to active HistoryBuffer
  var hb = h.append()
  hb.content = content

func len*(h: History): Natural = h.len
#func getActive*(h: History): HistoryBuffer = h.active # TODO: even good idea?
func getTimestamp*(h: History): DateTime = h.active.timestamp
func getContent*(h: History): string = h.active.content