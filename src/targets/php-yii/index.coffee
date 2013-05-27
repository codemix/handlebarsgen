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
  pattern: /^template\.html$/

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
       * @var CController $this The controller
       */
    ?>
    """
    footer: ""
    combinedHeader: """
    <?php $this->defineView("{id}}", function($scope) {
    ob_start();
    ?>
    """
    combinedFooter: """
    <?php
    return ob_get_clean();
    });?>
    """
