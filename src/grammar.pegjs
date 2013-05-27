/**
 * Simplistic AOT handlebars compiler, targetting PHP.
 */

start "Start"
  = content

content "Content"
  = c:(notTag / block / tag)+ {
    return {
      type: "content",
      body: c
    };
  }

notTag "Not Tag"
  = $(!("{{") .)+

tag "Tag"
  = "{{" e:(comment / partial / expression) "}}" {
      return e;
  }

comment "Comment"
  = "!" body:$(!"}}" .)* {
    return {
      type: "comment",
      body: body
    }
  }

partial "Partial"
  = ">" _ name:$[A-Za-z0-9_]+ {
    return {
      type: "partial",
      name: name
    }
  }

expression "Expression"
  = controlExpression
  / rawExpression
  / quotedExpression


controlExpression "Control Expression"
  = elseExpression

elseExpression "Else Expression"
  = "else" ![A-Za-z0-9_] {
    return {
      type: "elseExpression"
    }
  }

rawExpression "Raw Expression"
  = "{" e:callExpression "}" {
    return {
      type: "rawExpression",
      body: e
    };
  }

quotedExpression "Quoted Expression"
  = e:callExpression {
    return {
      type: "quotedExpression",
      body: e
    }
  }

callExpression "Call Expression"
  = head:identifierPart tail:(__ accessor)+ {
    return {
      type: "callExpression",
      subject: head,
      body: tail.map(function(item){
        return item[1];
      })
    }
  }
  / accessor

block "Block"
  = "{{#" name:identifierPart a:(__ accessor)? _ "}}" c:content "{{/" endName:identifierPart "}}" {
    if (name != endName)
      return null;
    return {
      type: "block",
      name: name,
      subject: (a ? a[1] : null),
      body: c
    }

  }

accessor "Accessor"
  = pathAccessor
  / plainAccessor
  / identifier
  / number
  / string

plainAccessor "Plain Accessor"
  = head:identifier tail:("." accessorPart)* {
    return {
      type: "accessor",
      head: head,
      tail: tail.map(function(item){
        return item[1];
      })
    };
  }


pathAccessor "Path Accessor"
  = dep:"../"+ head:identifier? tail:("." accessorPart)* {
    return {
      type: "pathAccessor",
      depth: dep.length,
      head: head,
      tail: tail.map(function(item){
        return item[1];
      })
    };
  }


accessorPart "Accessor Part"
  = number / string / identifierPart




identifier "Identifier"
  = thisIdentifier
  / reflectiveIdentifier
  / i:identifierPart {
    return {
      type: "identifier",
      name: i
    }
  }

thisIdentifier "This Identifier"
  = "this" ![A-Za-z0-9_] {
    return {
      type: "thisIdentifier",
      name: "this"
    }
  }

reflectiveIdentifier "Reflective Identifier"
  = keyIdentifier
  / "@" name:identifierPart {
    return {
      type: "reflectiveIdentifier",
      name: name
    }
  }

keyIdentifier "Key Identifier"
  = "@" name:("key" / "index") ![A-Za-z0-9_] {
    return {
      type: "keyIdentifier",
      name: name
    }
  }

identifierPart "Identifier Part"
  = $([A-Za-z][A-Za-z0-9_]*)

number "Number"
  = $[0-9]+

string "String"
  = "\"" body:$("\\\"" / (!"\"" .)+)* "\"" {
    return {
      type: "string",
      body: body
    };
  }

__ "Mandatory Whitespace"
  = $(whitespace+)

_ "Optional Whitespace"
  = __?


whitespace
  = [\u0009\u000B\u000C\u0020\u00A0\uFEFF\u1680\u180E\u2000-\u200A\u202F\u205F\u3000]
  / "\r" // ignored to support windows line endings
  / $("\\" "\r"? "\n")
