###
# Nodes
The different kinds of node in the AST
###

# Import the block helpers
Blocks = require "./blocks"

###
Helper method used for defining nodes
###
o = (name, toString) ->
  module.exports[name] = toString


o "content", ->
  @body.join ""

o "string", ->
  JSON.stringify @body


o "comment", ->
  "<?php /** #{@body} */ ?>"

o "partial", ->
  "<?=$this->partial(\"#{@name}\", $#{@scopeName})?>"

o "callExpression", ->
  "$this->#{@subject}(#{@body.join(', ')})"

o "rawExpression", ->
  "<?=#{@body}?>"

o "quotedExpression", ->
  "<?=$this->encode(#{@body})?>"

o "accessor", ->
  if @head.type is "identifier"
    content = ["$#{@scopeName}->#{@head.name}"]
  else
    content = ["$#{@head.name}"]

  for item in @tail
    if item is String parseInt item, 10
      content.push "[#{item}]"
    else
      content.push "->#{item}"
  content.join ""

o "pathAccessor", ->
  content = ["$#{@scopeName}"]
  content.push "->#{@head.name}" if @head

  for item in @tail
    if item is String parseInt item, 10
      content.push "[#{item}]"
    else
      content.push "->#{item}"
  content.join ""

o "identifier", ->
  if @scopeName?
    "$#{@scopeName}->#{@name}"
  else
    "$#{@name}"

o "thisIdentifier", ->
  "$#{@name}"

o "superIdentifier", ->
  "$#{@name}"

o "keyIdentifier", ->
  "$#{@name}"

o "reflectiveIdentifier", ->
  "$#{@name}"

o "block", ->
  if Blocks[@name]?
    Blocks[@name].call this
  else
    Blocks.custom.call this

o "elseExpression", ->
  "<?php else: ?>"
