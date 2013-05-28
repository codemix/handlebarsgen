###
# Nodes
The different kinds of node in the AST
###

# Import the block helpers
Blocks = require "./blocks"
Base = require "../php"

###
Helper method used for defining nodes
###
o = (name, toString) ->
  module.exports[name] = toString

# Include the base nodes
o name, node for name, node of Base.Nodes






o "partial", ->
  "<?=$this->renderPartial(\"#{@name}\", $#{@scopeName})?>"

o "quotedExpression", ->
  "<?=CHtml::encode(#{@body})?>"

o "block", ->
  if Blocks[@name]?
    Blocks[@name].call this
  else
    Blocks.custom.call this
