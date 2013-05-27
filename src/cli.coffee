fs = require "fs"
path = require "path"
optimist = require "optimist"
mkdirp = require "mkdirp"
Generator = require "./generator"
Targets = require "./targets"

###
Command line interface for handlebars-gen
###
module.exports = class CLI

  ###
  Initialize the CLI based on the command line options
  ###
  constructor: (options = optimist.argv) ->
    # Set the target platform
    if options.target?
      @target = Targets[options.target]
      throw new Error "No such target: #{options.target}" unless @target?
    else
      @target = Targets.php

    # Set whether or not to compile bare output, e.g. no header / footer templates
    if options.bare?
      @bare = options.bare
    else
      @bare = false

    # Set the pattern to use when finding templates
    if options.pattern?
      @pattern = new RegExp options.pattern
    else
      @pattern = @target.pattern

    # Set the file extension to use when generating templates
    @extname = options.extname or @target.extname

    # Set the file name or directory to output to
    if options.output?
      @output = path.resolve options.output
    else
      @output = null


    # Set the input
    if options._.length
      @input = options._
    else
      @input = null


    @generator = new Generator
      target: @target

  run: ->


    files = []
    if @input is null
      # read from stdin instead
      files.push
        id: "__stdin__"
        name: "__stdin__"
        folder: "__stdin__"
        original: "__stdin__"
        extname: ""
        ast: @generator.generate fs.readFileSync '/dev/stdin', 'utf8'
    else
      for item in @input
        resolved = path.resolve item
        if fs.statSync(item).isDirectory()
          files.push (@generateDir path.dirname(resolved), resolved)...
        else
          files.push @generateFile path.dirname(resolved), path.dirname(resolved), path.basename(resolved)

    @writeOutput files


  ###
  Write the output according
  ###
  writeOutput: (files) ->
    if @bare
      wrapperTemplates = {}
    else
      wrapperTemplates = @generator.compileWrapperTemplates()
    if @output?
      exists = fs.existsSync @output
      if exists
        stats = fs.statSync(@output)
        isDirectory = stats.isDirectory()
        isFile = stats.isFile()
      else
        isFile = /\.(\w+)$/.test @output
        isDirectory = not isFile

    if isDirectory
      for file in files
        targetFolder = path.join(@output, file.folder)
        mkdirp.sync targetFolder
        targetFile = path.join(targetFolder, "#{file.name}#{@extname}")
        fs.writeFile targetFile, @generator.wrapFile file, wrapperTemplates
      return


    if @output?
      if files.length > 1
        data = @target.combine files, wrapperTemplates
      else
        data = @generator.wrapFile file, wrapperTemplates
      targetFolder = mkdirp.sync path.dirname @output
      fs.writeFile @output, data
    else
      data = @target.combine files, wrapperTemplates
      process.stdout.write "#{data}\n"





  generateFile: (wd, folder, filename) ->
    extname = path.extname filename
    name = path.basename filename, extname
    folder = folder.substr(wd.length)
    original = path.join(wd, folder, filename)
    try
      ast = @generator.generate fs.readFileSync original, "utf8"
    catch error
      process.stdin.write [
        "Parse Error in #{original}: expected"
        error.expected.join(", ")
        "found"
        error.found
        "at line "
        error.line
        "offset"
        error.offset
        "\n"
      ].join " "
      process.exit(1)
    id: folder.substr(1).replace(path.sep, "/")
    name: name
    extname: extname
    folder: folder
    wd: wd
    original: original
    ast: ast

  ###
  Generate the
  ###
  generateDir: (wd, folder) ->
    files = []
    for item in fs.readdirSync path.join(folder)
      if fs.statSync(path.join(folder, item)).isDirectory()
        files.push @generateDir(wd, path.join(folder, item))...
      else if @pattern.test item
          files.push @generateFile wd, folder, item
    files

