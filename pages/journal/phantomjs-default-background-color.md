date: 2012-12-19
title: Default background color in PhantomJS screenshots

By default PhantomJS will rasterize pages with a transparent background
if the page does not set a background color on its `<body>`.
The official [PhantomJS FAQ][faq] offers this solution:

    ::javascript
    page.evaluate(function() {
        document.body.bgColor = 'white';
    });

The problem is that the style property you set on the body element will
override other potential background declarations the page has. All pages
will be rendered and rasterized with a white background color.

One solution is to inject a style declaration with a default white background
color for the body element and let the browser handle the cascade:

    ::javascript
    page.evaluate(function() {
      var style = document.createElement('style'),
          text = document.createTextNode('body { background: #fff }');
      style.setAttribute('type', 'text/css');
      style.appendChild(text);
      document.head.insertBefore(style, document.head.firstChild);
    });

[faq]: http://phantomjs.org/faq.html
