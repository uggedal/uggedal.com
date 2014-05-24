function req (path, cb) {
  var script = document.createElement('script');
  script.src = 'https://api.github.com' + path + '?callback=' + cb;

  document.head.appendChild(script);
}

function gh (path, txt) {
  return '<a href=https://github.com/' + path + '>' + txt + '</a></dt>'
}

function day (iso) {
  return iso.split('T')[0];
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
    '<p><a href=https://github.com/uggedal><em>All commits</em></a></p>',
  ].join('');

  return document.body.insertBefore(section, footer);
}

var section = init();
var MAX = 10;
var AUTHOR = 'eivind@uggedal.com';

function handler (res) {
  var i = 0;
  var date;
  var html = [];

  res.data.forEach(function (item) {
    if (item.type !== 'PushEvent') return;
    if (i+1 >= MAX) return;

    if (date !== day(item.created_at)) {
      date = day(item.created_at);
      html.push('<dt>' + date + '</dt>');
    }

    item.payload.commits.forEach(function (c) {
      if (c.author.email !== AUTHOR) return
      if (i++ >= MAX) return;

      html.push('<dd>');
      html.push(gh(item.repo.name, item.repo.name.replace(/^uggedal\//, '')))
      html.push(': ');
      html.push(gh(item.repo.name + '/commit/' + c.sha, c.message))
      html.push('</dd>');
    });

  });

  section.querySelector('dl').innerHTML = html.join('');
};


if (section) req('/users/uggedal/events/public', 'handler');
