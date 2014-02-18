function createCommitFeed() {
  if (document.location.pathname !== '/') return;

  var footer = document.querySelector('body > footer');

  var section = document.createElement('section');
  section.className = 'commit-feed';
  section.innerHTML = [
    '<header><h1>Latest Commits</h1></header>',
    '<p><a href=https://github.com/uggedal>All commits</a></p>',
  ].join('');

  document.body.insertBefore(section, footer);
}

createCommitFeed();
