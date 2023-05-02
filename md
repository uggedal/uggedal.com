#!/usr/bin/env python3

import sys

import pygments
import pygments.formatters
import pygments.lexers
import mistune

class Renderer(mistune.HTMLRenderer):
    formatter = pygments.formatters.HtmlFormatter()

    def block_code(self, text, lang=None):
        try:
            lexer = pygments.lexers.get_lexer_by_name(lang)
        except ValueError:
            lexer = pygments.lexers.TextLexer()
        return pygments.highlight(text, lexer, self.formatter)

sys.stdout.write(
    mistune.create_markdown(renderer=Renderer())(sys.stdin.read())
)
