module.exports =
  Nodes: require "./nodes"
  Blocks: require "./blocks"
  ###
  The default file extension for templates of this type
  ###
  extname: ".php"

  ###
  The pattern to use when looking for templates
  ###
  pattern: /\.html$/

  ###
  Combine the given (parsed, processed) files into one
  ###
  combine: (files, templates = {}) ->
    data = []
    for file in files
      wrapped = []
      content = []
      content.push templates.header(file) if templates.header
      content.push String file.ast
      content.push templates.footer(file) if templates.footer

      wrapped.push templates.combinedHeader file if templates.combinedHeader
      wrapped.push content.join ""
      wrapped.push templates.combinedFooter file if templates.combinedFooter
      data.push wrapped.join "\n"

    data.join "\n\n"

  ###
  The templates that should be used to wrap the contents
  ###
  templates:
    header: """
    <?php
      /**
       * WARNING: This file has been generated from a template. Changes you make here WILL be overridden.
       * @view {{id}}
       * @template {{folder}}/{{name}}{{extname}}
       *
       * @var mixed $scope The data scope
       */
    ?>
    """
    footer: ""
    combinedHeader: """
    <?php $this->defineView("{{id}}", function($scope) {
    ob_start();
    ?>
    """
    combinedFooter: """
    <?php
    return ob_get_clean();
    });?>
    """
