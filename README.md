# handlebars-gen

Extensible ahead-of-time (AOT) template transpiler for Handlebars, targeting languages other than JavaScript, e.g. PHP.


# Installation

    npm install handlebars-gen -g

# Usage

Can be used via the command line:

    handlebars-gen --target php --compile --output ./compiled ./src

use `handlebars-gen --help` for more information on individual commands.

Or as a library from within your node.js application:

    var Gen = require("handlebars-gen");

    var generator = new Gen.Generator({
      target: Gen.Targets['php']
    });

    fs.readFile("path/to/template", "utf8", function(err, data){
      if (err) throw err;
      var ast = generator.generate(data);
      console.log(ast.toString()); // the compiled output
      console.log(JSON.stringify(ast, null, 2)); // the node structure
    });





