import sys
import datetime

from flask import Flask, render_template
from flask.ext.flatpages import FlatPages, pygments_style_defs
from flask.ext.frozen import Freezer

DEBUG = True
FLATPAGES_AUTO_RELOAD = DEBUG
FLATPAGES_EXTENSION = '.md'
PAGE_DATE_FORMAT="%Y/%m/%d %H:%M:%S"

app = Flask(__name__)
app.config.from_object(__name__)

def parse_dates(pages):
    for p in pages:
        if 'date' in p.meta:
            p.meta['date'] = datetime.datetime.strptime(p.meta['date'],
                                                        PAGE_DATE_FORMAT)
    return pages

pages = parse_dates(FlatPages(app))

def get_latest_pages():
    latest = sorted(pages, reverse=True,
                    key=lambda p: p.meta['date'])
    return (p for p in latest if not 'draft' in p.meta)

@app.route('/')
def index():
    return render_template('index.html', pages=get_latest_pages())

@app.route('/pygments.css')
def pygments_css():
    return pygments_style_defs('tango'), 200, {'Content-Type': 'text/css'}

@app.route('/<path:path>/')
def page(path):
    page = pages.get_or_404(path)
    return render_template('page.html', page=page)

if __name__ == '__main__':
    if 'build' in sys.argv[1:]:
        Freezer(app)
    elif 'serve' in sys.argv[1:]:
        app.run(host='0.0.0.0', port=40404)
