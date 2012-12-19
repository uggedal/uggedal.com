import sys

from flask import Flask, render_template
from flask.ext.flatpages import FlatPages, pygments_style_defs
from flask.ext.frozen import Freezer
from werkzeug.contrib.atom import AtomFeed

DEBUG = True
FLATPAGES_AUTO_RELOAD = DEBUG
FLATPAGES_EXTENSION = '.md'
FREEZER_IGNORE_MIMETYPE_WARNINGS = True

BASE_URL = "http://uggedal.com"

app = Flask(__name__)
app.config.from_object(__name__)

articles = FlatPages(app)

def get_latest_entries():
    return sorted((p for p in articles if not 'draft' in p.meta \
                   and p.path.startswith('journal')),
                  reverse=True, key=lambda p: p.meta['date'])

@app.route('/')
def index():
    return render_template('index.html', articles=get_latest_entries()[:5])

@app.route('/pygments.css')
def pygments_css():
    return pygments_style_defs('solarized'), 200, {'Content-Type': 'text/css'}

@app.route('/journal/')
def journal():
    return render_template('journal.html', articles=get_latest_entries())

@app.route('/journal/index.atom')
def feed():
    feed = AtomFeed('Journal of Eivind Uggedal',
                    author='Eivind Uggedal',
                    feed_url=BASE_URL + "/journal/index.atom",
                    url=BASE_URL + "/journal")
    for article in get_latest_entries()[:5]:
        feed.add(article.meta['title'],
                 url=BASE_URL + "/" + article.path,
                 content=article.html,
                 content_type="html",
                 updated=article.meta['date'])
    return feed.get_response()

@app.route('/<path:path>/')
def article(path):
    article = articles.get_or_404(path)
    return render_template('article.html', article=article)

if __name__ == '__main__':
    if 'build' in sys.argv[1:]:
        app.config.DEBUG = False
        Freezer(app).freeze()
    elif 'serve' in sys.argv[1:]:
        port = sys.argv[2] if len(sys.argv) > 2 else 9294
        app.run(host='0.0.0.0', port=int(port))
