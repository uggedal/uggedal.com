#!/usr/bin/env python2.7

import sys

import pygments
import pygments.formatters
import pygments.lexers
import mistune

class Renderer(mistune.Renderer):
    formatter = pygments.formatters.HtmlFormatter()

    def block_code(self, text, lang):
        try:
            lexer = pygments.lexers.get_lexer_by_name(lang)
        except ValueError:
            lexer = pygments.lexers.TextLexer()
        return pygments.highlight(text, lexer, self.formatter)

sys.stdout.write(mistune.Markdown(Renderer())(sys.stdin.read()))
