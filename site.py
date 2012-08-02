import sys

from flask import Flask, render_template
from flask.ext.flatpages import FlatPages, pygments_style_defs
from flask.ext.frozen import Freezer

DEBUG = True
FLATPAGES_AUTO_RELOAD = DEBUG
FLATPAGES_EXTENSION = '.md'

app = Flask(__name__)
app.config.from_object(__name__)

articles = FlatPages(app)

def get_latest_articles():
    return sorted((p for p in articles if not 'draft' in p.meta),
                  reverse=True, key=lambda p: p.meta['date'])

@app.route('/')
def index():
    return render_template('index.html', articles=get_latest_articles()[:5])

@app.route('/pygments.css')
def pygments_css():
    return pygments_style_defs('trac'), 200, {'Content-Type': 'text/css'}

@app.route('/journal')
def journal():
    return render_template('journal.html', articles=get_latest_articles())

@app.route('/<path:path>/')
def article(path):
    article = articles.get_or_404(path)
    return render_template('article.html', article=article)

if __name__ == '__main__':
    if 'build' in sys.argv[1:]:
        Freezer(app)
    elif 'serve' in sys.argv[1:]:
        app.run(host='0.0.0.0', port=40404)
