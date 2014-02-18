function req (path, cb) {
  var script = document.createElement('script');
  script.src = 'https://api.github.com' + path + '?callback=' + cb;

  document.head.appendChild(script);
}

function gh (path, txt) {
  return '<a href=https://github.com/' + path + '>' + txt + '</a></dt>'
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
  var repo;
  var html = [];

  res.data.forEach(function (item) {
    if (item.type !== 'PushEvent') return;
    if (i+1 >= MAX) return;

    if (repo !== item.repo.name) {
      repo = item.repo.name;
      html.push('<dt>' + gh(repo, repo) + '</dt>');
    }

    item.payload.commits.forEach(function (c) {
      if (i++ >= MAX) return;

      html.push('<dd>' + gh(repo + '/commit/' + c.sha, c.message) + '</dd>');
    });

  });

  section.querySelector('dl').innerHTML = html.join('');
};


if (section) req('/users/uggedal/events/public', 'handler');
