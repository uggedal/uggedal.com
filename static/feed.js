function req (path, cb) {
  var script = document.createElement('script');
  script.src = 'https://api.github.com' + path + '?callback=' + cb;

  document.head.appendChild(script);
}

function init () {
  if (document.location.pathname !== '/') return;

  var footer = document.querySelector('body > footer');

  var section = document.createElement('section');
  section.className = 'commit-feed';
  section.innerHTML = [
    '<header><h1>Latest Commits</h1></header>',
    '<ol>',
    '</ol>',
    '<p><a href=https://github.com/uggedal>All commits</a></p>',
  ].join('');

  return document.body.insertBefore(section, footer);
}

var section = init();
var MAX = 10;

function handler (res) {
  var i = 0;

  section.querySelector('ol').innerHTML = res.data.map(function (item) {
    if (item.type !== 'PushEvent') return '';

    return item.payload.commits.map(function (commit) {
      if (i++ >= MAX) return;
      return '<li>' + commit.message + '</li>';
    }).join('');
  }).join('');
};


if (section) {
  req('/users/uggedal/events/public', 'handler');
}
