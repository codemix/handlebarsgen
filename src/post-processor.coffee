###
The post-processor operates on the parsed AST and does things like
assigning the correct scope to variables.
###
module.exports = class PostProcessor
  ###
  Initialize the post-processor.
  ###
  constructor: (config = {}) ->
    for attribute, value of config
      @[attribute] = value

  ###
  Post-process an AST
  ###
  postprocess: (ast) ->
    stack = []
    keyStack = []
    keyName = ->
      String.fromCharCode 105 + (keyStack.length - 1)
    scopeName = ->
      if stack.length is 0
        "scope"
      else
        "context#{String.fromCharCode(65 + (stack.length - 1))}"
    Nodes = @Nodes
    visit = (node) =>
      # skip strings when processing
      return if node is String node

      # Apply the right toString function
      if Nodes[node.type]
        node.toString = Nodes[node.type]
      else
        throw new Error "Invalid Node: #{node.type}"

      # Whether or not to pop the stack at the end of the method
      popStack = false
      popKeyStack = false

      # Members that should be processed before stack manipulation

      visit node.subject if node.subject?


      # Stack manipulators and variable replacers

      switch node.type
        when "block"
          if node.name is "each"
            stack.push scopeName()
            keyStack.push keyName()
            node.scopeName = scopeName()
            node.keyName = keyName()
            popStack = true
            popKeyStack = true
          else if node.name is "with"
            stack.push scopeName()
            node.scopeName = scopeName()
            node.keyName = keyName()
            popStack = true
        when "partial"
          node.scopeName = scopeName()
        when "thisIdentifier"
          node.name = scopeName()
        when "keyIdentifier"
          node.name = keyName()
        when "identifier"
          node.scopeName = scopeName()
        when "accessor"
          node.scopeName = scopeName()
          visit node.head
        when "pathAccessor"
          node.scopeName = stack[stack.length - node.depth]




      # Visit the node children, if any

      if node.body?
        if Array.isArray node.body
          visit child for child in node.body
        else
          visit node.body


      stack.pop() if popStack
      keyStack.pop() if popKeyStack
      undefined


    visit ast
    ast




