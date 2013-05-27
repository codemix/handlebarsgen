Handlebars = require "handlebars"
Parser = require "./parser"
PostProcessor = require "./post-processor"
Targets = require "./targets"
module.exports = class Generator
  ###
  Initialize the generator
  ###
  constructor: (config = {}) ->
    for attribute, value of config
      @[attribute] = value
    @target or= Targets.php
    @postProcessor or= new PostProcessor @target


  ###
  Parse the input and return an AST that can be rendered
  as the target language.
  ###
  generate: (input) ->
    @postProcessor.postprocess Parser.parse input

  ###
  Compile the wrapper templates
  ###
  compileWrapperTemplates: ->
    templates = {}
    for name, source of @target.templates
      templates[name] = Handlebars.compile source if source
    templates

  ###
  Wrap the given file in header and footer templates
  ###
  wrapFile: (file, templates = {}) ->
    data = []
    data.push templates.header file if templates.header?
    data.push String file.ast
    data.push templates.footer file if templates.footer?

    data.join ''

