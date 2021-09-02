import chibi/history

var h1 = initHistory() # Unlimited history, 1 HistoryBuffer
h1.add("Hello, world!") # 2 HistoryBuffers
assert h1.getContent() == "Hello, world!"
h1.add("Hello, Nim!") # 3 HistoryBuffers
assert h1.getContent() == "Hello, Nim!"
assert h1.len == 3 # Hence ...
for x in 0..9:
  h1.add($x)
assert h1.len == 13 # 3 + 10

var h2 = initHistory(3)
h2.add("Hello, world!")
h2.add("Hello, Nim!")
h2.add("Foo")
h2.add("Bar") 
assert h2.len == 3 # Limit
assert h2.getContent == "Bar"
assert h2.undo() == true
assert h2.getContent == "Foo"
assert h2.undo() == true
assert h2.getContent == "Hello, Nim!"
assert h2.undo() == false # No more prev
assert h2.redo() == true
assert h2.getContent == "Foo"
assert h2.redo() == true
assert h2.getContent == "Bar"
assert h2.redo() == false # No more next
assert h2.len == 3 # Still the limit

discard h2.undo()
discard h2.undo()
assert h2.len == 3 # Yet still
h2.add("Zzzz") 
assert h2.len == 2 # No more
assert h2.redo() == false