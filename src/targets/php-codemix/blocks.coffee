Base = require "../php"

###
Helper method used for defining nodes
###
o = (name, toString) ->
  module.exports[name] = toString


# include the parent blocks
o name, block for name, block of Base.Blocks


###
A layout block
###
o "layout", ->

  "<?php $this->beginContent(#{@subject})?>#{@body}<?php $this->endContent(); ?>"

###
A custom block
###
o "custom", ->
  "<?php ob_start(); ?>#{@body}<?php $this->#{@name}(#{@subject}, ob_get_clean()); ?>"
