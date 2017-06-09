describe "YAML grammar", ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage("language-otl")

    runs ->
      grammar = atom.grammars.grammarForScopeName('source.otl')

  it "parses the grammar", ->
    expect(grammar).toBeTruthy()
    expect(grammar.scopeName).toBe "source.otl"

  it "selects the grammar for cloud config files", ->
    waitsForPromise ->
      atom.workspace.open('cloud.config')

    runs ->
      expect(atom.workspace.getActiveTextEditor().getGrammar()).toBe grammar

  describe "strings", ->
    describe "double quoted", ->
      it "parses escaped quotes", ->
        {tokens} = grammar.tokenizeLine("\"I am \\\"escaped\\\"\"")
        expect(tokens[0]).toEqual value: "\"", scopes: ["source.otl", "string.quoted.double.otl", "punctuation.definition.string.begin.otl"]
        expect(tokens[1]).toEqual value: "I am ", scopes: ["source.otl", "string.quoted.double.otl"]
        expect(tokens[2]).toEqual value: "\\\"", scopes: ["source.otl", "string.quoted.double.otl", "constant.character.escape.otl"]
        expect(tokens[3]).toEqual value: "escaped", scopes: ["source.otl", "string.quoted.double.otl"]
        expect(tokens[4]).toEqual value: "\\\"", scopes: ["source.otl", "string.quoted.double.otl", "constant.character.escape.otl"]
        expect(tokens[5]).toEqual value: "\"", scopes: ["source.otl", "string.quoted.double.otl", "punctuation.definition.string.end.otl"]

        {tokens} = grammar.tokenizeLine("key: \"I am \\\"escaped\\\"\"")
        expect(tokens[0]).toEqual value: "key", scopes: ["source.otl", "entity.name.tag.otl"]
        expect(tokens[1]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
        expect(tokens[2]).toEqual value: " ", scopes: ["source.otl"]
        expect(tokens[3]).toEqual value: "\"", scopes: ["source.otl", "string.quoted.double.otl", "punctuation.definition.string.begin.otl"]
        expect(tokens[4]).toEqual value: "I am ", scopes: ["source.otl", "string.quoted.double.otl"]
        expect(tokens[5]).toEqual value: "\\\"", scopes: ["source.otl", "string.quoted.double.otl", "constant.character.escape.otl"]
        expect(tokens[6]).toEqual value: "escaped", scopes: ["source.otl", "string.quoted.double.otl"]
        expect(tokens[7]).toEqual value: "\\\"", scopes: ["source.otl", "string.quoted.double.otl", "constant.character.escape.otl"]
        expect(tokens[8]).toEqual value: "\"", scopes: ["source.otl", "string.quoted.double.otl", "punctuation.definition.string.end.otl"]

      it "parses other escape sequences", ->
        {tokens} = grammar.tokenizeLine("\"I am \\escaped\"")
        expect(tokens[0]).toEqual value: "\"", scopes: ["source.otl", "string.quoted.double.otl", "punctuation.definition.string.begin.otl"]
        expect(tokens[1]).toEqual value: "I am ", scopes: ["source.otl", "string.quoted.double.otl"]
        expect(tokens[2]).toEqual value: "\\e", scopes: ["source.otl", "string.quoted.double.otl", "constant.character.escape.otl"]
        expect(tokens[3]).toEqual value: "scaped", scopes: ["source.otl", "string.quoted.double.otl"]
        expect(tokens[4]).toEqual value: "\"", scopes: ["source.otl", "string.quoted.double.otl", "punctuation.definition.string.end.otl"]

        {tokens} = grammar.tokenizeLine('"\\uAb123"')
        expect(tokens[1]).toEqual value: "\\uAb12", scopes: ["source.otl", "string.quoted.double.otl", "constant.character.escape.otl"]
        expect(tokens[2]).toEqual value: "3", scopes: ["source.otl", "string.quoted.double.otl"]

        {tokens} = grammar.tokenizeLine('"\\UAb123Fe90"')
        expect(tokens[1]).toEqual value: "\\UAb123Fe9", scopes: ["source.otl", "string.quoted.double.otl", "constant.character.escape.otl"]
        expect(tokens[2]).toEqual value: "0", scopes: ["source.otl", "string.quoted.double.otl"]

        {tokens} = grammar.tokenizeLine('"\\x200"')
        expect(tokens[1]).toEqual value: "\\x20", scopes: ["source.otl", "string.quoted.double.otl", "constant.character.escape.otl"]
        expect(tokens[2]).toEqual value: "0", scopes: ["source.otl", "string.quoted.double.otl"]

        {tokens} = grammar.tokenizeLine('"\\ hi"')
        expect(tokens[1]).toEqual value: "\\ ", scopes: ["source.otl", "string.quoted.double.otl", "constant.character.escape.otl"]
        expect(tokens[2]).toEqual value: "hi", scopes: ["source.otl", "string.quoted.double.otl"]

      it "parses invalid escape sequences", ->
        {tokens} = grammar.tokenizeLine('"\\uqerww"')
        expect(tokens[1]).toEqual value: "\\uqerw", scopes: ["source.otl", "string.quoted.double.otl", "invalid.illegal.escape.otl"]
        expect(tokens[2]).toEqual value: "w", scopes: ["source.otl", "string.quoted.double.otl"]

        {tokens} = grammar.tokenizeLine('"\\U0123456GF"')
        expect(tokens[1]).toEqual value: "\\U0123456G", scopes: ["source.otl", "string.quoted.double.otl", "invalid.illegal.escape.otl"]
        expect(tokens[2]).toEqual value: "F", scopes: ["source.otl", "string.quoted.double.otl"]

        {tokens} = grammar.tokenizeLine('"\\x2Q1"')
        expect(tokens[1]).toEqual value: "\\x2Q", scopes: ["source.otl", "string.quoted.double.otl", "invalid.illegal.escape.otl"]
        expect(tokens[2]).toEqual value: "1", scopes: ["source.otl", "string.quoted.double.otl"]

        {tokens} = grammar.tokenizeLine('"\\c3"')
        expect(tokens[1]).toEqual value: "\\c", scopes: ["source.otl", "string.quoted.double.otl", "invalid.illegal.escape.otl"]
        expect(tokens[2]).toEqual value: "3", scopes: ["source.otl", "string.quoted.double.otl"]

    describe "single quoted", ->
      it "parses escaped single quotes", ->
        {tokens} = grammar.tokenizeLine("'I am ''escaped'''")
        expect(tokens[0]).toEqual value: "'", scopes: ["source.otl", "string.quoted.single.otl", "punctuation.definition.string.begin.otl"]
        expect(tokens[1]).toEqual value: "I am ", scopes: ["source.otl", "string.quoted.single.otl"]
        expect(tokens[2]).toEqual value: "''", scopes: ["source.otl", "string.quoted.single.otl", "constant.character.escape.otl"]
        expect(tokens[3]).toEqual value: "escaped", scopes: ["source.otl", "string.quoted.single.otl"]
        expect(tokens[4]).toEqual value: "''", scopes: ["source.otl", "string.quoted.single.otl", "constant.character.escape.otl"]
        expect(tokens[5]).toEqual value: "'", scopes: ["source.otl", "string.quoted.single.otl", "punctuation.definition.string.end.otl"]

        {tokens} = grammar.tokenizeLine("key: 'I am ''escaped'''")
        expect(tokens[0]).toEqual value: "key", scopes: ["source.otl", "entity.name.tag.otl"]
        expect(tokens[1]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
        expect(tokens[2]).toEqual value: " ", scopes: ["source.otl"]
        expect(tokens[3]).toEqual value: "'", scopes: ["source.otl", "string.quoted.single.otl", "punctuation.definition.string.begin.otl"]
        expect(tokens[4]).toEqual value: "I am ", scopes: ["source.otl", "string.quoted.single.otl"]
        expect(tokens[5]).toEqual value: "''", scopes: ["source.otl", "string.quoted.single.otl", "constant.character.escape.otl"]
        expect(tokens[6]).toEqual value: "escaped", scopes: ["source.otl", "string.quoted.single.otl"]
        expect(tokens[7]).toEqual value: "''", scopes: ["source.otl", "string.quoted.single.otl", "constant.character.escape.otl"]
        expect(tokens[8]).toEqual value: "'", scopes: ["source.otl", "string.quoted.single.otl", "punctuation.definition.string.end.otl"]

      it "does not recognize backslashes as escape characters", ->
        {tokens} = grammar.tokenizeLine("'I am not \\escaped'")
        expect(tokens[0]).toEqual value: "'", scopes: ["source.otl", "string.quoted.single.otl", "punctuation.definition.string.begin.otl"]
        expect(tokens[1]).toEqual value: "I am not \\escaped", scopes: ["source.otl", "string.quoted.single.otl"]
        expect(tokens[2]).toEqual value: "'", scopes: ["source.otl", "string.quoted.single.otl", "punctuation.definition.string.end.otl"]

    describe "text blocks", ->
      it "parses simple content", ->
        lines = grammar.tokenizeLines """
        key: |
          content here
          second line
        """
        expect(lines[0][0]).toEqual value: "key", scopes: ["source.otl", "entity.name.tag.otl"]
        expect(lines[0][1]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
        expect(lines[1][0]).toEqual value: "  content here", scopes: ["source.otl", "string.unquoted.block.otl"]
        expect(lines[2][0]).toEqual value: "  second line", scopes: ["source.otl", "string.unquoted.block.otl"]

      it "parses content with empty lines", ->
        lines = grammar.tokenizeLines """
        key: |
          content here

          second line
        """
        expect(lines[0][0]).toEqual value: "key", scopes: ["source.otl", "entity.name.tag.otl"]
        expect(lines[0][1]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
        expect(lines[1][0]).toEqual value: "  content here", scopes: ["source.otl", "string.unquoted.block.otl"]
        expect(lines[2][0]).toEqual value: "", scopes: ["source.otl", "string.unquoted.block.otl"]
        expect(lines[3][0]).toEqual value: "  second line", scopes: ["source.otl", "string.unquoted.block.otl"]

      it "parses keys with decimals", ->
        lines = grammar.tokenizeLines """
        2.0: |
          content here
          second line
        """
        expect(lines[0][0]).toEqual value: "2.0", scopes: ["source.otl", "entity.name.tag.otl"]
        expect(lines[0][1]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
        expect(lines[1][0]).toEqual value: "  content here", scopes: ["source.otl", "string.unquoted.block.otl"]
        expect(lines[2][0]).toEqual value: "  second line", scopes: ["source.otl", "string.unquoted.block.otl"]

      it "parses keys with quotes", ->
        lines = grammar.tokenizeLines """
        single'quotes': |
          content here
        double"quotes": >
          content here
        """
        expect(lines[0][0]).toEqual value: "single'quotes'", scopes: ["source.otl", "entity.name.tag.otl"]
        expect(lines[0][1]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
        expect(lines[1][0]).toEqual value: "  content here", scopes: ["source.otl", "string.unquoted.block.otl"]
        expect(lines[2][0]).toEqual value: "double\"quotes\"", scopes: ["source.otl", "entity.name.tag.otl"]
        expect(lines[2][1]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
        expect(lines[3][0]).toEqual value: "  content here", scopes: ["source.otl", "string.unquoted.block.otl"]

      it "parses keys with quotes in sequences", ->
        lines = grammar.tokenizeLines """
        - single'quotes': |
          content here
        - double"quotes": >
          content here
        """
        expect(lines[0][0]).toEqual value: "-", scopes: ["source.otl", "punctuation.definition.entry.otl"]
        expect(lines[0][2]).toEqual value: "single'quotes'", scopes: ["source.otl", "entity.name.tag.otl"]
        expect(lines[0][3]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
        expect(lines[1][0]).toEqual value: "  content here", scopes: ["source.otl", "string.unquoted.block.otl"]
        expect(lines[2][0]).toEqual value: "-", scopes: ["source.otl", "punctuation.definition.entry.otl"]
        expect(lines[2][2]).toEqual value: "double\"quotes\"", scopes: ["source.otl", "entity.name.tag.otl"]
        expect(lines[2][3]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
        expect(lines[3][0]).toEqual value: "  content here", scopes: ["source.otl", "string.unquoted.block.otl"]

      it "parses keys with quotes in sequences even when not using | or >", ->
        lines = grammar.tokenizeLines """
        - single'quotes':
          content here
        - double"quotes":
          content here
        """
        expect(lines[0][0]).toEqual value: "-", scopes: ["source.otl", "punctuation.definition.entry.otl"]
        expect(lines[0][2]).toEqual value: "single'quotes'", scopes: ["source.otl", "entity.name.tag.otl"]
        expect(lines[0][3]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
        expect(lines[1][1]).toEqual value: "content here", scopes: ["source.otl", "string.unquoted.otl"]
        expect(lines[2][0]).toEqual value: "-", scopes: ["source.otl", "punctuation.definition.entry.otl"]
        expect(lines[2][2]).toEqual value: "double\"quotes\"", scopes: ["source.otl", "entity.name.tag.otl"]
        expect(lines[2][3]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
        expect(lines[3][1]).toEqual value: "content here", scopes: ["source.otl", "string.unquoted.otl"]

      it "parses keys with spaces", ->
        lines = grammar.tokenizeLines """
        a space: |
          content here
        more than one space: >
          content here
        space after : |
          content here
        """
        expect(lines[0][0]).toEqual value: "a space", scopes: ["source.otl", "entity.name.tag.otl"]
        expect(lines[0][1]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
        expect(lines[1][0]).toEqual value: "  content here", scopes: ["source.otl", "string.unquoted.block.otl"]
        expect(lines[2][0]).toEqual value: "more than one space", scopes: ["source.otl", "entity.name.tag.otl"]
        expect(lines[2][1]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
        expect(lines[3][0]).toEqual value: "  content here", scopes: ["source.otl", "string.unquoted.block.otl"]
        expect(lines[4][0]).toEqual value: "space after", scopes: ["source.otl", "entity.name.tag.otl"]
        expect(lines[4][2]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
        expect(lines[5][0]).toEqual value: "  content here", scopes: ["source.otl", "string.unquoted.block.otl"]

      it "parses keys with spaces in sequences", ->
        lines = grammar.tokenizeLines """
        - a space: |
          content here
        - more than one space: >
          content here
        - space after : |
          content here
        """
        expect(lines[0][0]).toEqual value: "-", scopes: ["source.otl", "punctuation.definition.entry.otl"]
        expect(lines[0][2]).toEqual value: "a space", scopes: ["source.otl", "entity.name.tag.otl"]
        expect(lines[0][3]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
        expect(lines[1][0]).toEqual value: "  content here", scopes: ["source.otl", "string.unquoted.block.otl"]
        expect(lines[2][0]).toEqual value: "-", scopes: ["source.otl", "punctuation.definition.entry.otl"]
        expect(lines[2][2]).toEqual value: "more than one space", scopes: ["source.otl", "entity.name.tag.otl"]
        expect(lines[2][3]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
        expect(lines[3][0]).toEqual value: "  content here", scopes: ["source.otl", "string.unquoted.block.otl"]
        expect(lines[4][0]).toEqual value: "-", scopes: ["source.otl", "punctuation.definition.entry.otl"]
        expect(lines[4][2]).toEqual value: "space after", scopes: ["source.otl", "entity.name.tag.otl"]
        expect(lines[4][4]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
        expect(lines[5][0]).toEqual value: "  content here", scopes: ["source.otl", "string.unquoted.block.otl"]

      it "properly parses through pound signs in blocks", ->
        lines = grammar.tokenizeLines """
        key: |
          # this is not a legit comment
          unquoted block
          ### this is just a markdown header
          another unquoted block
        """
        expect(lines[0][0]).toEqual value: "key", scopes: ["source.otl", "entity.name.tag.otl"]
        expect(lines[0][1]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
        expect(lines[1][0]).toEqual value: "  # this is not a legit comment", scopes: ["source.otl", "string.unquoted.block.otl"]
        expect(lines[2][0]).toEqual value: "  unquoted block", scopes: ["source.otl", "string.unquoted.block.otl"]
        expect(lines[3][0]).toEqual value: "  ### this is just a markdown header", scopes: ["source.otl", "string.unquoted.block.otl"]
        expect(lines[4][0]).toEqual value: "  another unquoted block", scopes: ["source.otl", "string.unquoted.block.otl"]

      it "parses keys following blocks in sequences", ->
        lines = grammar.tokenizeLines """
        - textblock: >
            multiline
            text
          key with spaces: following text
        """
        expect(lines[0][0]).toEqual value: "-", scopes: ["source.otl", "punctuation.definition.entry.otl"]
        expect(lines[0][2]).toEqual value: "textblock", scopes: ["source.otl", "entity.name.tag.otl"]
        expect(lines[0][3]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
        expect(lines[1][0]).toEqual value: "    multiline", scopes: ["source.otl", "string.unquoted.block.otl"]
        expect(lines[2][0]).toEqual value: "    text", scopes: ["source.otl", "string.unquoted.block.otl"]
        expect(lines[3][0]).toEqual value: "  ", scopes: ["source.otl"]
        expect(lines[3][1]).toEqual value: "key with spaces", scopes: ["source.otl", "entity.name.tag.otl"]
        expect(lines[3][2]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
        expect(lines[3][3]).toEqual value: " ", scopes: ["source.otl"]
        expect(lines[3][4]).toEqual value: "following text", scopes: ["source.otl", "string.unquoted.otl"]

      it "parses content even when not using | or >", ->
        lines = grammar.tokenizeLines """
        - textblock:
            multiline
            text
          key: following text
        """
        expect(lines[0][0]).toEqual value: "-", scopes: ["source.otl", "punctuation.definition.entry.otl"]
        expect(lines[0][2]).toEqual value: "textblock", scopes: ["source.otl", "entity.name.tag.otl"]
        expect(lines[0][3]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
        expect(lines[1][1]).toEqual value: "multiline", scopes: ["source.otl", "string.unquoted.otl"]
        expect(lines[2][1]).toEqual value: "text", scopes: ["source.otl", "string.unquoted.otl"]
        expect(lines[3][0]).toEqual value: "  ", scopes: ["source.otl"]
        expect(lines[3][1]).toEqual value: "key", scopes: ["source.otl", "entity.name.tag.otl"]
        expect(lines[3][2]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
        expect(lines[3][3]).toEqual value: " ", scopes: ["source.otl"]
        expect(lines[3][4]).toEqual value: "following text", scopes: ["source.otl", "string.unquoted.otl"]

      describe "parses content with unindented empty lines", ->
        it "ending the content", ->
          lines = grammar.tokenizeLines """
          key: |
            content here

            second line
          """
          expect(lines[0][0]).toEqual value: "key", scopes: ["source.otl", "entity.name.tag.otl"]
          expect(lines[0][1]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
          expect(lines[0][3]).toEqual value: "|", scopes: ["source.otl", "string.unquoted.block.otl"]
          expect(lines[1][0]).toEqual value: "  content here", scopes: ["source.otl", "string.unquoted.block.otl"]
          expect(lines[2][0]).toEqual value: "", scopes: ["source.otl", "string.unquoted.block.otl"]
          expect(lines[3][0]).toEqual value: "  second line", scopes: ["source.otl", "string.unquoted.block.otl"]

        it "ending with new element", ->
          lines = grammar.tokenizeLines """
          key: |
            content here

            second line
          other: hi
          """
          expect(lines[0][0]).toEqual value: "key", scopes: ["source.otl", "entity.name.tag.otl"]
          expect(lines[0][1]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
          expect(lines[0][3]).toEqual value: "|", scopes: ["source.otl", "string.unquoted.block.otl"]
          expect(lines[1][0]).toEqual value: "  content here", scopes: ["source.otl", "string.unquoted.block.otl"]
          expect(lines[2][0]).toEqual value: "", scopes: ["source.otl", "string.unquoted.block.otl"]
          expect(lines[3][0]).toEqual value: "  second line", scopes: ["source.otl", "string.unquoted.block.otl"]
          expect(lines[4][0]).toEqual value: "other", scopes: ["source.otl", "entity.name.tag.otl"]
          expect(lines[4][1]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
          expect(lines[4][2]).toEqual value: " ", scopes: ["source.otl"]
          expect(lines[4][3]).toEqual value: "hi", scopes: ["source.otl", "string.unquoted.otl"]

        it "ending with new element, part of list", ->
          lines = grammar.tokenizeLines """
           - key: |
               content here

               second line
           - other: hi
          """
          expect(lines[0][0]).toEqual value: "-", scopes: ["source.otl", "punctuation.definition.entry.otl"]
          expect(lines[0][2]).toEqual value: "key", scopes: ["source.otl", "entity.name.tag.otl"]
          expect(lines[0][3]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
          expect(lines[0][5]).toEqual value: "|", scopes: ["source.otl", "string.unquoted.block.otl"]
          expect(lines[1][0]).toEqual value: "    content here", scopes: ["source.otl", "string.unquoted.block.otl"]
          expect(lines[2][0]).toEqual value: "", scopes: ["source.otl", "string.unquoted.block.otl"]
          expect(lines[3][0]).toEqual value: "    second line", scopes: ["source.otl", "string.unquoted.block.otl"]
          expect(lines[4][0]).toEqual value: "-", scopes: ["source.otl", "punctuation.definition.entry.otl"]
          expect(lines[4][1]).toEqual value: " ", scopes: ["source.otl"]
          expect(lines[4][2]).toEqual value: "other", scopes: ["source.otl", "entity.name.tag.otl"]
          expect(lines[4][3]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
          expect(lines[4][4]).toEqual value: " ", scopes: ["source.otl"]
          expect(lines[4][5]).toEqual value: "hi", scopes: ["source.otl", "string.unquoted.otl"]

        it "ending with twice unindented new element", ->
          lines = grammar.tokenizeLines """
          root:
            key: |
              content here

              second line
          other: hi
          """
          expect(lines[1][1]).toEqual value: "key", scopes: ["source.otl", "entity.name.tag.otl"]
          expect(lines[1][2]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
          expect(lines[1][4]).toEqual value: "|", scopes: ["source.otl", "string.unquoted.block.otl"]
          expect(lines[2][0]).toEqual value: "    content here", scopes: ["source.otl", "string.unquoted.block.otl"]
          expect(lines[3][0]).toEqual value: "", scopes: ["source.otl", "string.unquoted.block.otl"]
          expect(lines[4][0]).toEqual value: "    second line", scopes: ["source.otl", "string.unquoted.block.otl"]
          expect(lines[5][0]).toEqual value: "other", scopes: ["source.otl", "entity.name.tag.otl"]
          expect(lines[5][1]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
          expect(lines[5][2]).toEqual value: " ", scopes: ["source.otl"]
          expect(lines[5][3]).toEqual value: "hi", scopes: ["source.otl", "string.unquoted.otl"]

        it "ending with an indented comment", ->
          lines = grammar.tokenizeLines """
          root:
            key: |
              content here

              second line
            # hi
          """
          expect(lines[1][1]).toEqual value: "key", scopes: ["source.otl", "entity.name.tag.otl"]
          expect(lines[1][2]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
          expect(lines[1][4]).toEqual value: "|", scopes: ["source.otl", "string.unquoted.block.otl"]
          expect(lines[2][0]).toEqual value: "    content here", scopes: ["source.otl", "string.unquoted.block.otl"]
          expect(lines[3][0]).toEqual value: "", scopes: ["source.otl", "string.unquoted.block.otl"]
          expect(lines[4][0]).toEqual value: "    second line", scopes: ["source.otl", "string.unquoted.block.otl"]
          expect(lines[5][0]).toEqual value: "  ", scopes: ["source.otl"]
          expect(lines[5][1]).toEqual value: "#", scopes: ["source.otl", "comment.line.number-sign.otl", "punctuation.definition.comment.otl"]
          expect(lines[5][2]).toEqual value: " hi", scopes: ["source.otl", "comment.line.number-sign.otl"]

    it "does not confuse keys and strings", ->
      {tokens} = grammar.tokenizeLine("- 'Section 2.4: 3, 6abc, 12ab, 30, 32a'")
      expect(tokens[0]).toEqual value: "-", scopes: ["source.otl", "punctuation.definition.entry.otl"]
      expect(tokens[2]).toEqual value: "'", scopes: ["source.otl", "string.quoted.single.otl", "punctuation.definition.string.begin.otl"]
      expect(tokens[3]).toEqual value: "Section 2.4: 3, 6abc, 12ab, 30, 32a", scopes: ["source.otl", "string.quoted.single.otl"]

  it "parses the non-specific tag indicator before values", ->
    {tokens} = grammar.tokenizeLine("key: ! 'hi'")
    expect(tokens[0]).toEqual value: "key", scopes: ["source.otl", "entity.name.tag.otl"]
    expect(tokens[1]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
    expect(tokens[2]).toEqual value: " ", scopes: ["source.otl"]
    expect(tokens[3]).toEqual value: "!", scopes: ["source.otl", "punctuation.definition.tag.non-specific.otl"]
    expect(tokens[5]).toEqual value: "'", scopes: ["source.otl", "string.quoted.single.otl", "punctuation.definition.string.begin.otl"]
    expect(tokens[6]).toEqual value: "hi", scopes: ["source.otl", "string.quoted.single.otl"]
    expect(tokens[7]).toEqual value: "'", scopes: ["source.otl", "string.quoted.single.otl",  "punctuation.definition.string.end.otl"]

  it "parses nested keys", ->
    lines = grammar.tokenizeLines """
      first:
        second:
          third: 3
          fourth: "4th"
    """

    expect(lines[0][0]).toEqual value: "first", scopes: ["source.otl", "entity.name.tag.otl"]
    expect(lines[0][1]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]

    expect(lines[1][0]).toEqual value: "  ", scopes: ["source.otl"]
    expect(lines[1][1]).toEqual value: "second", scopes: ["source.otl", "entity.name.tag.otl"]
    expect(lines[1][2]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]

    expect(lines[2][0]).toEqual value: "    ", scopes: ["source.otl"]
    expect(lines[2][1]).toEqual value: "third", scopes: ["source.otl", "entity.name.tag.otl"]
    expect(lines[2][2]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
    expect(lines[2][3]).toEqual value: " ", scopes: ["source.otl"]
    expect(lines[2][4]).toEqual value: "3", scopes: ["source.otl", "constant.numeric.otl"]

    expect(lines[3][0]).toEqual value: "    ", scopes: ["source.otl"]
    expect(lines[3][1]).toEqual value: "fourth", scopes: ["source.otl", "entity.name.tag.otl"]
    expect(lines[3][2]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
    expect(lines[3][3]).toEqual value: " ", scopes: ["source.otl"]
    expect(lines[3][4]).toEqual value: "\"", scopes: ["source.otl", "string.quoted.double.otl", "punctuation.definition.string.begin.otl"]
    expect(lines[3][5]).toEqual value: "4th", scopes: ["source.otl", "string.quoted.double.otl"]
    expect(lines[3][6]).toEqual value: "\"", scopes: ["source.otl", "string.quoted.double.otl", "punctuation.definition.string.end.otl"]

  it "parses keys and values", ->
    lines = grammar.tokenizeLines """
      first: 1st
      second: 2nd
      third: th{ree}
      fourth:invalid
    """

    expect(lines[0][0]).toEqual value: "first", scopes: ["source.otl", "entity.name.tag.otl"]
    expect(lines[0][1]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
    expect(lines[0][2]).toEqual value: " ", scopes: ["source.otl"]
    expect(lines[0][3]).toEqual value: "1st", scopes: ["source.otl", "string.unquoted.otl"]

    expect(lines[1][0]).toEqual value: "second", scopes: ["source.otl", "entity.name.tag.otl"]
    expect(lines[1][1]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
    expect(lines[1][2]).toEqual value: " ", scopes: ["source.otl"]
    expect(lines[1][3]).toEqual value: "2nd", scopes: ["source.otl", "string.unquoted.otl"]

    expect(lines[2][0]).toEqual value: "third", scopes: ["source.otl", "entity.name.tag.otl"]
    expect(lines[2][1]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
    expect(lines[2][2]).toEqual value: " ", scopes: ["source.otl"]
    expect(lines[2][3]).toEqual value: "th{ree}", scopes: ["source.otl", "string.unquoted.otl"]

    expect(lines[3][0]).toEqual value: "fourth:invalid", scopes: ["source.otl", "string.unquoted.otl"]

  it "parses quoted keys", ->
    lines = grammar.tokenizeLines """
      'G@role:deployer':
        - deployer
    """

    expect(lines[0][0]).toEqual value: "'", scopes: ["source.otl", "string.quoted.single.otl", "punctuation.definition.string.begin.otl"]
    expect(lines[0][1]).toEqual value: "G@role:deployer", scopes: ["source.otl", "string.quoted.single.otl", "entity.name.tag.otl"]
    expect(lines[0][2]).toEqual value: "'", scopes: ["source.otl", "string.quoted.single.otl", "punctuation.definition.string.end.otl"]
    expect(lines[0][3]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]

    lines = grammar.tokenizeLines """
      "G@role:deployer":
        - deployer
    """

    expect(lines[0][0]).toEqual value: '"', scopes: ["source.otl", "string.quoted.double.otl", "punctuation.definition.string.begin.otl"]
    expect(lines[0][1]).toEqual value: "G@role:deployer", scopes: ["source.otl", "string.quoted.double.otl", "entity.name.tag.otl"]
    expect(lines[0][2]).toEqual value: '"', scopes: ["source.otl", "string.quoted.double.otl", "punctuation.definition.string.end.otl"]
    expect(lines[0][3]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]

  it "parses comments at the beginning of lines", ->
    lines = grammar.tokenizeLines """
      # first: 1
        # second
      ##
    """

    expect(lines[0][0]).toEqual value: "#", scopes: ["source.otl", "comment.line.number-sign.otl", "punctuation.definition.comment.otl"]
    expect(lines[0][1]).toEqual value: " first: 1", scopes: ["source.otl", "comment.line.number-sign.otl"]

    expect(lines[1][0]).toEqual value: "  ", scopes: ["source.otl"]
    expect(lines[1][1]).toEqual value: "#", scopes: ["source.otl", "comment.line.number-sign.otl", "punctuation.definition.comment.otl"]
    expect(lines[1][2]).toEqual value: " second", scopes: ["source.otl", "comment.line.number-sign.otl"]

    expect(lines[2][0]).toEqual value: "#", scopes: ["source.otl", "comment.line.number-sign.otl", "punctuation.definition.comment.otl"]
    expect(lines[2][1]).toEqual value: "#", scopes: ["source.otl", "comment.line.number-sign.otl"]

  it "parses comments at the end of lines", ->
    lines = grammar.tokenizeLines """
      first: 1 # foo
      second: 2nd  #bar
      third: "3"
      fourth: four#
    """

    expect(lines[0][0]).toEqual value: "first", scopes: ["source.otl", "entity.name.tag.otl"]
    expect(lines[0][1]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
    expect(lines[0][3]).toEqual value: "1", scopes: ["source.otl", "constant.numeric.otl"]
    expect(lines[0][5]).toEqual value: "#", scopes: ["source.otl", "comment.line.number-sign.otl", "punctuation.definition.comment.otl"]
    expect(lines[0][6]).toEqual value: " foo", scopes: ["source.otl", "comment.line.number-sign.otl"]

    expect(lines[1][0]).toEqual value: "second", scopes: ["source.otl", "entity.name.tag.otl"]
    expect(lines[1][1]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
    expect(lines[1][2]).toEqual value: " ", scopes: ["source.otl"]
    expect(lines[1][3]).toEqual value: "2nd  ", scopes: ["source.otl", "string.unquoted.otl"]
    expect(lines[1][4]).toEqual value: "#", scopes: ["source.otl", "comment.line.number-sign.otl", "punctuation.definition.comment.otl"]
    expect(lines[1][5]).toEqual value: "bar", scopes: ["source.otl", "comment.line.number-sign.otl"]

    expect(lines[2][0]).toEqual value: "third", scopes: ["source.otl", "entity.name.tag.otl"]
    expect(lines[2][1]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
    expect(lines[2][2]).toEqual value: " ", scopes: ["source.otl"]
    expect(lines[2][3]).toEqual value: "\"", scopes: ["source.otl", "string.quoted.double.otl", "punctuation.definition.string.begin.otl"]
    expect(lines[2][4]).toEqual value: "3", scopes: ["source.otl", "string.quoted.double.otl"]
    expect(lines[2][5]).toEqual value: "\"", scopes: ["source.otl", "string.quoted.double.otl", "punctuation.definition.string.end.otl"]

    expect(lines[3][0]).toEqual value: "fourth", scopes: ["source.otl", "entity.name.tag.otl"]
    expect(lines[3][1]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
    expect(lines[3][2]).toEqual value: " ", scopes: ["source.otl"]
    expect(lines[3][3]).toEqual value: "four#", scopes: ["source.otl", "string.unquoted.otl"]

    lines = grammar.tokenizeLines """
      multiline: # comment!
        This should still be a string # another comment!
        Ditto
        # Guess what this is
        String
      # comment
    """

    expect(lines[0][3]).toEqual value: "#", scopes: ["source.otl", "comment.line.number-sign.otl", "punctuation.definition.comment.otl"]
    expect(lines[1][1]).toEqual value: "This should still be a string ", scopes: ["source.otl", "string.unquoted.otl"]
    expect(lines[1][2]).toEqual value: "#", scopes: ["source.otl", "comment.line.number-sign.otl", "punctuation.definition.comment.otl"]
    expect(lines[2][1]).toEqual value: "Ditto", scopes: ["source.otl", "string.unquoted.otl"]
    expect(lines[3][1]).toEqual value: "#", scopes: ["source.otl", "comment.line.number-sign.otl", "punctuation.definition.comment.otl"]
    expect(lines[4][1]).toEqual value: "String", scopes: ["source.otl", "string.unquoted.otl"]
    expect(lines[5][0]).toEqual value: "#", scopes: ["source.otl", "comment.line.number-sign.otl", "punctuation.definition.comment.otl"]

  it "does not confuse keys and comments", ->
    {tokens} = grammar.tokenizeLine("- Entry 2 # This colon breaks syntax highlighting: see?")
    expect(tokens[0]).toEqual value: "-", scopes: ["source.otl", "punctuation.definition.entry.otl"]
    expect(tokens[3]).toEqual value: "#", scopes: ["source.otl", "comment.line.number-sign.otl", "punctuation.definition.comment.otl"]
    expect(tokens[4]).toEqual value: " This colon breaks syntax highlighting: see?", scopes: ["source.otl", "comment.line.number-sign.otl"]

  it "does not confuse keys and unquoted strings", ->
    {tokens} = grammar.tokenizeLine("- { role: common }")
    expect(tokens[0]).toEqual value: "-", scopes: ["source.otl", "punctuation.definition.entry.otl"]
    expect(tokens[2]).toEqual value: "{ role: common }", scopes: ["source.otl", "string.unquoted.otl"]

  it "parses colons in key names", ->
    lines = grammar.tokenizeLines """
      colon::colon: 1
      colon::colon: 2nd
      colon::colon: "3"
      colon: "this is another : colon"
      colon: "this is another :colon"
    """

    expect(lines[0][0]).toEqual value: "colon::colon", scopes: ["source.otl", "entity.name.tag.otl"]
    expect(lines[0][1]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
    expect(lines[0][3]).toEqual value: "1", scopes: ["source.otl", "constant.numeric.otl"]

    expect(lines[1][0]).toEqual value: "colon::colon", scopes: ["source.otl", "entity.name.tag.otl"]
    expect(lines[1][1]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
    expect(lines[1][2]).toEqual value: " ", scopes: ["source.otl"]
    expect(lines[1][3]).toEqual value: "2nd", scopes: ["source.otl", "string.unquoted.otl"]

    expect(lines[2][0]).toEqual value: "colon::colon", scopes: ["source.otl", "entity.name.tag.otl"]
    expect(lines[2][1]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
    expect(lines[2][2]).toEqual value: " ", scopes: ["source.otl"]
    expect(lines[2][3]).toEqual value: "\"", scopes: ["source.otl", "string.quoted.double.otl", "punctuation.definition.string.begin.otl"]
    expect(lines[2][4]).toEqual value: "3", scopes: ["source.otl", "string.quoted.double.otl"]
    expect(lines[2][5]).toEqual value: "\"", scopes: ["source.otl", "string.quoted.double.otl", "punctuation.definition.string.end.otl"]

    expect(lines[3][0]).toEqual value: "colon", scopes: ["source.otl", "entity.name.tag.otl"]
    expect(lines[3][1]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
    expect(lines[3][2]).toEqual value: " ", scopes: ["source.otl"]
    expect(lines[3][3]).toEqual value: "\"", scopes: ["source.otl", "string.quoted.double.otl", "punctuation.definition.string.begin.otl"]
    expect(lines[3][4]).toEqual value: "this is another : colon", scopes: ["source.otl", "string.quoted.double.otl"]
    expect(lines[3][5]).toEqual value: "\"", scopes: ["source.otl", "string.quoted.double.otl", "punctuation.definition.string.end.otl"]

    expect(lines[4][0]).toEqual value: "colon", scopes: ["source.otl", "entity.name.tag.otl"]
    expect(lines[4][1]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
    expect(lines[4][2]).toEqual value: " ", scopes: ["source.otl"]
    expect(lines[4][3]).toEqual value: "\"", scopes: ["source.otl", "string.quoted.double.otl", "punctuation.definition.string.begin.otl"]
    expect(lines[4][4]).toEqual value: "this is another :colon", scopes: ["source.otl", "string.quoted.double.otl"]
    expect(lines[4][5]).toEqual value: "\"", scopes: ["source.otl", "string.quoted.double.otl", "punctuation.definition.string.end.otl"]

  it "parses spaces in key names", ->
    lines = grammar.tokenizeLines """
      spaced out: 1
      more        spaces: 2nd
      with quotes: "3"
    """

    expect(lines[0][0]).toEqual value: "spaced out", scopes: ["source.otl", "entity.name.tag.otl"]
    expect(lines[0][1]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
    expect(lines[0][3]).toEqual value: "1", scopes: ["source.otl", "constant.numeric.otl"]

    expect(lines[1][0]).toEqual value: "more        spaces", scopes: ["source.otl", "entity.name.tag.otl"]
    expect(lines[1][1]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
    expect(lines[1][2]).toEqual value: " ", scopes: ["source.otl"]
    expect(lines[1][3]).toEqual value: "2nd", scopes: ["source.otl", "string.unquoted.otl"]

    expect(lines[2][0]).toEqual value: "with quotes", scopes: ["source.otl", "entity.name.tag.otl"]
    expect(lines[2][1]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
    expect(lines[2][2]).toEqual value: " ", scopes: ["source.otl"]
    expect(lines[2][3]).toEqual value: "\"", scopes: ["source.otl", "string.quoted.double.otl", "punctuation.definition.string.begin.otl"]
    expect(lines[2][4]).toEqual value: "3", scopes: ["source.otl", "string.quoted.double.otl"]
    expect(lines[2][5]).toEqual value: "\"", scopes: ["source.otl", "string.quoted.double.otl", "punctuation.definition.string.end.otl"]

  it "parses quotes in unquoted key names", ->
    lines = grammar.tokenizeLines """
      General Tso's Chicken: 1
      Dwayne "The Rock" Johnson: 2nd
      possessives': "3"
      Conan "the Barbarian": '4'
    """

    expect(lines[0][0]).toEqual value: "General Tso's Chicken", scopes: ["source.otl", "entity.name.tag.otl"]
    expect(lines[0][1]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
    expect(lines[0][3]).toEqual value: "1", scopes: ["source.otl", "constant.numeric.otl"]

    expect(lines[1][0]).toEqual value: "Dwayne \"The Rock\" Johnson", scopes: ["source.otl", "entity.name.tag.otl"]
    expect(lines[1][1]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
    expect(lines[1][2]).toEqual value: " ", scopes: ["source.otl"]
    expect(lines[1][3]).toEqual value: "2nd", scopes: ["source.otl", "string.unquoted.otl"]

    expect(lines[2][0]).toEqual value: "possessives'", scopes: ["source.otl", "entity.name.tag.otl"]
    expect(lines[2][1]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
    expect(lines[2][2]).toEqual value: " ", scopes: ["source.otl"]
    expect(lines[2][3]).toEqual value: "\"", scopes: ["source.otl", "string.quoted.double.otl", "punctuation.definition.string.begin.otl"]
    expect(lines[2][4]).toEqual value: "3", scopes: ["source.otl", "string.quoted.double.otl"]
    expect(lines[2][5]).toEqual value: "\"", scopes: ["source.otl", "string.quoted.double.otl", "punctuation.definition.string.end.otl"]

    expect(lines[3][0]).toEqual value: "Conan \"the Barbarian\"", scopes: ["source.otl", "entity.name.tag.otl"]
    expect(lines[3][1]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
    expect(lines[3][2]).toEqual value: " ", scopes: ["source.otl"]
    expect(lines[3][3]).toEqual value: "'", scopes: ["source.otl", "string.quoted.single.otl", "punctuation.definition.string.begin.otl"]
    expect(lines[3][4]).toEqual value: "4", scopes: ["source.otl", "string.quoted.single.otl"]
    expect(lines[3][5]).toEqual value: "'", scopes: ["source.otl", "string.quoted.single.otl", "punctuation.definition.string.end.otl"]

  it "parses the merge-key tag", ->
    {tokens} = grammar.tokenizeLine "<<: *variable"
    expect(tokens[0]).toEqual value: "<<", scopes: ["source.otl", "entity.name.tag.merge.otl"]
    expect(tokens[1]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
    expect(tokens[2]).toEqual value: " ", scopes: ["source.otl"]
    expect(tokens[3]).toEqual value: "*", scopes: ["source.otl", "variable.other.otl", "punctuation.definition.variable.otl"]
    expect(tokens[4]).toEqual value: "variable", scopes: ["source.otl", "variable.other.otl"]

    {tokens} = grammar.tokenizeLine "<< : *variable"
    expect(tokens[0]).toEqual value: "<<", scopes: ["source.otl", "entity.name.tag.merge.otl"]
    expect(tokens[1]).toEqual value: " ", scopes: ["source.otl"]
    expect(tokens[2]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
    expect(tokens[3]).toEqual value: " ", scopes: ["source.otl"]
    expect(tokens[4]).toEqual value: "*", scopes: ["source.otl", "variable.other.otl", "punctuation.definition.variable.otl"]
    expect(tokens[5]).toEqual value: "variable", scopes: ["source.otl", "variable.other.otl"]

    {tokens} = grammar.tokenizeLine "<<:*variable"
    expect(tokens[0]).toEqual value: "<<:*variable", scopes: ["source.otl", "string.unquoted.otl"]

  it "parses local tags", ->
    {tokens} = grammar.tokenizeLine "multiline: !something >"
    expect(tokens[3]).toEqual value: "!", scopes: ["source.otl", "keyword.other.tag.local.otl", "punctuation.definition.tag.local.otl"]
    expect(tokens[4]).toEqual value: "something", scopes: ["source.otl", "keyword.other.tag.local.otl"]
    expect(tokens[6]).toEqual value: ">", scopes: ["source.otl", "string.unquoted.block.otl"]

    {tokens} = grammar.tokenizeLine "- !tag"
    expect(tokens[2]).toEqual value: "!", scopes: ["source.otl", "keyword.other.tag.local.otl", "punctuation.definition.tag.local.otl"]
    expect(tokens[3]).toEqual value: "tag", scopes: ["source.otl", "keyword.other.tag.local.otl"]

    {tokens} = grammar.tokenizeLine "- !"
    expect(tokens[0]).toEqual value: "- !", scopes: ["source.otl", "string.unquoted.otl"]

    {tokens} = grammar.tokenizeLine "- !!"
    expect(tokens[0]).toEqual value: "- !!", scopes: ["source.otl", "string.unquoted.otl"]

  it "parses the !!omap directive", ->
    {tokens} = grammar.tokenizeLine "hello: !!omap"
    expect(tokens[0]).toEqual value: "hello", scopes: ["source.otl", "entity.name.tag.otl"]
    expect(tokens[1]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
    expect(tokens[2]).toEqual value: " ", scopes: ["source.otl"]
    expect(tokens[3]).toEqual value: "!!", scopes: ["source.otl", "keyword.other.omap.otl", "punctuation.definition.tag.omap.otl"]
    expect(tokens[4]).toEqual value: "omap", scopes: ["source.otl", "keyword.other.omap.otl"]

    {tokens} = grammar.tokenizeLine "- 'hello': !!omap"
    expect(tokens[0]).toEqual value: "-", scopes: ["source.otl", "punctuation.definition.entry.otl"]
    expect(tokens[1]).toEqual value: " ", scopes: ["source.otl"]
    expect(tokens[2]).toEqual value: "'", scopes: ["source.otl", "string.quoted.single.otl", "punctuation.definition.string.begin.otl"]
    expect(tokens[3]).toEqual value: "hello", scopes: ["source.otl", "string.quoted.single.otl", "entity.name.tag.otl"]
    expect(tokens[4]).toEqual value: "'", scopes: ["source.otl", "string.quoted.single.otl", "punctuation.definition.string.end.otl"]
    expect(tokens[5]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
    expect(tokens[6]).toEqual value: " ", scopes: ["source.otl"]
    expect(tokens[7]).toEqual value: "!!", scopes: ["source.otl", "keyword.other.omap.otl", "punctuation.definition.tag.omap.otl"]
    expect(tokens[8]).toEqual value: "omap", scopes: ["source.otl", "keyword.other.omap.otl"]

    {tokens} = grammar.tokenizeLine "hello:!!omap"
    expect(tokens[0]).toEqual value: "hello:!!omap", scopes: ["source.otl", "string.unquoted.otl"]

  it "parses dates in YYYY-MM-DD format", ->
    {tokens} = grammar.tokenizeLine "- date: 2001-01-01"
    expect(tokens[0]).toEqual value: "-", scopes: ["source.otl", "punctuation.definition.entry.otl"]
    expect(tokens[1]).toEqual value: " ", scopes: ["source.otl"]
    expect(tokens[2]).toEqual value: "date", scopes: ["source.otl", "entity.name.tag.otl"]
    expect(tokens[3]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
    expect(tokens[4]).toEqual value: " ", scopes: ["source.otl"]
    expect(tokens[5]).toEqual value: "2001-01-01", scopes: ["source.otl", "constant.other.date.otl"]

    {tokens} = grammar.tokenizeLine "apocalypse: 2012-12-21"
    expect(tokens[0]).toEqual value: "apocalypse", scopes: ["source.otl", "entity.name.tag.otl"]
    expect(tokens[1]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
    expect(tokens[2]).toEqual value: " ", scopes: ["source.otl"]
    expect(tokens[3]).toEqual value: "2012-12-21", scopes: ["source.otl", "constant.other.date.otl"]

    {tokens} = grammar.tokenizeLine "'the apocalypse is nigh': 2012-12-21"
    expect(tokens[0]).toEqual value: "'", scopes: ["source.otl", "string.quoted.single.otl", "punctuation.definition.string.begin.otl"]
    expect(tokens[1]).toEqual value: "the apocalypse is nigh", scopes: ["source.otl", "string.quoted.single.otl", "entity.name.tag.otl"]
    expect(tokens[2]).toEqual value: "'", scopes: ["source.otl", "string.quoted.single.otl", "punctuation.definition.string.end.otl"]
    expect(tokens[3]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
    expect(tokens[4]).toEqual value: " ", scopes: ["source.otl"]
    expect(tokens[5]).toEqual value: "2012-12-21", scopes: ["source.otl", "constant.other.date.otl"]

    lines = grammar.tokenizeLines """
      multiline:
        - 2001-01-01
          2001-01-01
    """
    expect(lines[1][3]).toEqual value: "2001-01-01", scopes: ["source.otl", "constant.other.date.otl"]
    expect(lines[2][1]).toEqual value: "2001-01-01", scopes: ["source.otl", "constant.other.date.otl"]

    {tokens} = grammar.tokenizeLine "- 2001-01-01"
    expect(tokens[0]).toEqual value: "-", scopes: ["source.otl", "punctuation.definition.entry.otl"]
    expect(tokens[1]).toEqual value: " ", scopes: ["source.otl"]
    expect(tokens[2]).toEqual value: "2001-01-01", scopes: ["source.otl", "constant.other.date.otl"]

    {tokens} = grammar.tokenizeLine "- 07-04-1776"
    expect(tokens[0]).toEqual value: "-", scopes: ["source.otl", "punctuation.definition.entry.otl"]
    expect(tokens[1]).toEqual value: " ", scopes: ["source.otl"]
    expect(tokens[2]).toEqual value: "07-04-1776", scopes: ["source.otl", "string.unquoted.otl"]

    {tokens} = grammar.tokenizeLine "- nope 2001-01-01"
    expect(tokens[0]).toEqual value: "-", scopes: ["source.otl", "punctuation.definition.entry.otl"]
    expect(tokens[1]).toEqual value: " ", scopes: ["source.otl"]
    expect(tokens[2]).toEqual value: "nope 2001-01-01", scopes: ["source.otl", "string.unquoted.otl"]

    {tokens} = grammar.tokenizeLine "- 2001-01-01 uh oh"
    expect(tokens[0]).toEqual value: "-", scopes: ["source.otl", "punctuation.definition.entry.otl"]
    expect(tokens[1]).toEqual value: " ", scopes: ["source.otl"]
    expect(tokens[2]).toEqual value: "2001-01-01 uh oh", scopes: ["source.otl", "string.unquoted.otl"]

  it "parses numbers", ->
    {tokens} = grammar.tokenizeLine "- meaning of life: 42"
    expect(tokens[0]).toEqual value: "-", scopes: ["source.otl", "punctuation.definition.entry.otl"]
    expect(tokens[1]).toEqual value: " ", scopes: ["source.otl"]
    expect(tokens[2]).toEqual value: "meaning of life", scopes: ["source.otl", "entity.name.tag.otl"]
    expect(tokens[3]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
    expect(tokens[4]).toEqual value: " ", scopes: ["source.otl"]
    expect(tokens[5]).toEqual value: "42", scopes: ["source.otl", "constant.numeric.otl"]

    {tokens} = grammar.tokenizeLine "hex: 0x726Fa"
    expect(tokens[0]).toEqual value: "hex", scopes: ["source.otl", "entity.name.tag.otl"]
    expect(tokens[1]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
    expect(tokens[2]).toEqual value: " ", scopes: ["source.otl"]
    expect(tokens[3]).toEqual value: "0x726Fa", scopes: ["source.otl", "constant.numeric.otl"]

    {tokens} = grammar.tokenizeLine "- 0.7e-9001"
    expect(tokens[0]).toEqual value: "-", scopes: ["source.otl", "punctuation.definition.entry.otl"]
    expect(tokens[1]).toEqual value: " ", scopes: ["source.otl"]
    expect(tokens[2]).toEqual value: "0.7e-9001", scopes: ["source.otl", "constant.numeric.otl"]

    {tokens} = grammar.tokenizeLine "'over 9000': 9001"
    expect(tokens[0]).toEqual value: "'", scopes: ["source.otl", "string.quoted.single.otl", "punctuation.definition.string.begin.otl"]
    expect(tokens[1]).toEqual value: "over 9000", scopes: ["source.otl", "string.quoted.single.otl", "entity.name.tag.otl"]
    expect(tokens[2]).toEqual value: "'", scopes: ["source.otl", "string.quoted.single.otl", "punctuation.definition.string.end.otl"]
    expect(tokens[3]).toEqual value: ":", scopes: ["source.otl", "punctuation.separator.key-value.otl"]
    expect(tokens[4]).toEqual value: " ", scopes: ["source.otl"]
    expect(tokens[5]).toEqual value: "9001", scopes: ["source.otl", "constant.numeric.otl"]

    lines = grammar.tokenizeLines """
      multiline:
        - 3.14f
          3.14f
    """
    expect(lines[1][3]).toEqual value: "3.14f", scopes: ["source.otl", "constant.numeric.otl"]
    expect(lines[2][1]).toEqual value: "3.14f", scopes: ["source.otl", "constant.numeric.otl"]

    {tokens} = grammar.tokenizeLine "- pi 3.14"
    expect(tokens[0]).toEqual value: "-", scopes: ["source.otl", "punctuation.definition.entry.otl"]
    expect(tokens[1]).toEqual value: " ", scopes: ["source.otl"]
    expect(tokens[2]).toEqual value: "pi 3.14", scopes: ["source.otl", "string.unquoted.otl"]

    {tokens} = grammar.tokenizeLine "- 3.14 uh oh"
    expect(tokens[0]).toEqual value: "-", scopes: ["source.otl", "punctuation.definition.entry.otl"]
    expect(tokens[1]).toEqual value: " ", scopes: ["source.otl"]
    expect(tokens[2]).toEqual value: "3.14 uh oh", scopes: ["source.otl", "string.unquoted.otl"]

  describe "variables", ->
    it "tokenizes them", ->
      {tokens} = grammar.tokenizeLine "&variable"
      expect(tokens[0]).toEqual value: "&", scopes: ["source.otl", "variable.other.otl", "punctuation.definition.variable.otl"]
      expect(tokens[1]).toEqual value: "variable", scopes: ["source.otl", "variable.other.otl"]

      {tokens} = grammar.tokenizeLine "*variable"
      expect(tokens[0]).toEqual value: "*", scopes: ["source.otl", "variable.other.otl", "punctuation.definition.variable.otl"]
      expect(tokens[1]).toEqual value: "variable", scopes: ["source.otl", "variable.other.otl"]

      {tokens} = grammar.tokenizeLine "&v3ryc001"
      expect(tokens[0]).toEqual value: "&", scopes: ["source.otl", "variable.other.otl", "punctuation.definition.variable.otl"]
      expect(tokens[1]).toEqual value: "v3ryc001", scopes: ["source.otl", "variable.other.otl"]

      {tokens} = grammar.tokenizeLine "& variable"
      expect(tokens[0]).toEqual value: "& variable", scopes: ["source.otl", "string.unquoted.otl"]

      {tokens} = grammar.tokenizeLine "&variable hey"
      expect(tokens[0]).toEqual value: "&variable hey", scopes: ["source.otl", "string.unquoted.otl"]

  describe "constants", ->
    it "tokenizes true, false, and null as constants", ->
      {tokens} = grammar.tokenizeLine "key: true"
      expect(tokens[3]).toEqual value: "true", scopes: ["source.otl", "constant.language.otl"]

      {tokens} = grammar.tokenizeLine "key: false"
      expect(tokens[3]).toEqual value: "false", scopes: ["source.otl", "constant.language.otl"]

      {tokens} = grammar.tokenizeLine "key: null"
      expect(tokens[3]).toEqual value: "null", scopes: ["source.otl", "constant.language.otl"]

      {tokens} = grammar.tokenizeLine "key: True"
      expect(tokens[3]).toEqual value: "True", scopes: ["source.otl", "constant.language.otl"]

      {tokens} = grammar.tokenizeLine "key: False"
      expect(tokens[3]).toEqual value: "False", scopes: ["source.otl", "constant.language.otl"]

      {tokens} = grammar.tokenizeLine "key: Null"
      expect(tokens[3]).toEqual value: "Null", scopes: ["source.otl", "constant.language.otl"]

      {tokens} = grammar.tokenizeLine "key: TRUE"
      expect(tokens[3]).toEqual value: "TRUE", scopes: ["source.otl", "constant.language.otl"]

      {tokens} = grammar.tokenizeLine "key: FALSE"
      expect(tokens[3]).toEqual value: "FALSE", scopes: ["source.otl", "constant.language.otl"]

      {tokens} = grammar.tokenizeLine "key: NULL"
      expect(tokens[3]).toEqual value: "NULL", scopes: ["source.otl", "constant.language.otl"]

      {tokens} = grammar.tokenizeLine "key: ~"
      expect(tokens[3]).toEqual value: "~", scopes: ["source.otl", "constant.language.otl"]

      {tokens} = grammar.tokenizeLine "key: true$"
      expect(tokens[3]).toEqual value: "true$", scopes: ["source.otl", "string.unquoted.otl"]

      {tokens} = grammar.tokenizeLine "key: true false"
      expect(tokens[3]).toEqual value: "true false", scopes: ["source.otl", "string.unquoted.otl"]

    it "does not tokenize keys as constants", ->
      {tokens} = grammar.tokenizeLine "true: something"
      expect(tokens[0]).toEqual value: "true", scopes: ["source.otl", "entity.name.tag.otl"]

  describe "structures", ->
    it "tokenizes directives end markers", ->
      {tokens} = grammar.tokenizeLine "---"
      expect(tokens[0]).toEqual value: "---", scopes: ["source.otl", "punctuation.definition.directives.end.otl"]

      {tokens} = grammar.tokenizeLine " ---"
      expect(tokens[1]).not.toEqual value: "---", scopes: ["source.otl", "punctuation.definition.directives.end.otl"]

    it "tokenizes document end markers", ->
      {tokens} = grammar.tokenizeLine "..."
      expect(tokens[0]).toEqual value: "...", scopes: ["source.otl", "punctuation.definition.document.end.otl"]

    it "tokenizes structures in an actual YAML document", ->
      lines = grammar.tokenizeLines """
        ---
        time: 20:03:20
        player: Sammy Sosa
        action: strike (miss)
        ...
        ---
        time: 20:03:47
        player: Sammy Sosa
        action: grand slam
        ...
      """
      expect(lines[0][0]).toEqual value: "---", scopes: ["source.otl", "punctuation.definition.directives.end.otl"]
      expect(lines[4][0]).toEqual value: "...", scopes: ["source.otl", "punctuation.definition.document.end.otl"]
      expect(lines[5][0]).toEqual value: "---", scopes: ["source.otl", "punctuation.definition.directives.end.otl"]
      expect(lines[9][0]).toEqual value: "...", scopes: ["source.otl", "punctuation.definition.document.end.otl"]

  describe "tabs", ->
    it "marks them as invalid", ->
      {tokens} = grammar.tokenizeLine "\t\ttabs:"
      expect(tokens[0]).toEqual value: '\t\t', scopes: ['source.otl', 'invalid.illegal.whitespace.otl']
