import sys

from flask import Flask, render_template
from flask.ext.flatpages import FlatPages, pygments_style_defs
from flask.ext.frozen import Freezer

DEBUG = True
FLATPAGES_AUTO_RELOAD = DEBUG
FLATPAGES_EXTENSION = '.md'

app = Flask(__name__)
app.config.from_object(__name__)
pages = FlatPages(app)
freezer = Freezer(app)

@app.route('/')
def index():
    return render_template('index.html', pages=pages)

@app.route('/pygments.css')
def pygments_css():
    return pygments_style_defs('tango'), 200, {'Content-Type': 'text/css'}

@app.route('/<path:path>/')
def page(path):
    page = pages.get_or_404(path)
    return render_template('page.html', page=page)

if __name__ == '__main__':
    if 'build' in sys.argv[1:]:
        freezer.freeze()
    elif 'serve' in sys.argv[1:]:
        app.run(host='0.0.0.0', port=40404)
