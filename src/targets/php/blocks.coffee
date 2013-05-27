###
Helper method used for defining nodes
###
o = (name, toString) ->
  module.exports[name] = toString


###
An `each` block
###
o "each", ->
  "<?php foreach(#{@subject} as $#{@keyName} => $#{@scopeName}): ?>#{@body}<?php endforeach; ?>"

###
An `if` block
###
o "if", ->
  "<?php if (#{@subject}): ?>#{@body}<?php endif; ?>"

###
An `unless` block
###
o "unless", ->
  "<?php if (!(#{@subject})): ?>#{@body}<?php endif; ?>"


###
A `with` block
###
o "with", ->
  "<?php $#{@scopeName} = #{@subject}; ?>#{@body}"

###
A custom block
###
o "custom", ->
  "<?php ob_start(); ?>#{@body}<?php $this->#{@name}(#{@subject}, ob_get_clean()); ?>"
