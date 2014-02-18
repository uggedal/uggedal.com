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
    '<dl>',
    '</dl>',
    '<p><a href=https://github.com/uggedal>All commits</a></p>',
  ].join('');

  return document.body.insertBefore(section, footer);
}

var section = init();
var MAX = 10;

function handler (res) {
  var i = 0;
  var lastRepo;
  var html = [];

  res.data.forEach(function (item) {
    if (item.type !== 'PushEvent') return;
    if (i+1 >= MAX) return;

    if (lastRepo !== item.repo.name) {
      lastRepo = item.repo.name;
      html.push('<dt>' + lastRepo + '</dt>');
    }

    item.payload.commits.forEach(function (commit) {
      if (i++ >= MAX) return;

      html.push('<dd>' + commit.message + '</dd>');
    });

  });

  section.querySelector('dl').innerHTML = html.join('');
};


if (section) {
  req('/users/uggedal/events/public', 'handler');
}
