(function(doc, win) {

  var queryForEach = function(selector, fn, ctx) {
    [].forEach.call((ctx ? ctx : doc).querySelectorAll(selector), fn);
  };

  var getStyle = function(el, prop) {
    return doc.defaultView.getComputedStyle(el, "")[prop];
  };

  var throttle = function(fn, delay) {
    var timer = null;
    return function () {
      var context = this, args = arguments;
      clearTimeout(timer);
      timer = setTimeout(function () {
        fn.apply(context, args);
      }, delay);
    };
  };

  doc.addEventListener("DOMContentLoaded", function() {
    responsiveTables();
  }, false);

  win.addEventListener('resize', function () {
    throttle(responsiveTables(), 50);
  }, false);

  var prependHeadersToTableCells = function(table) {
    var headers = [];
    queryForEach("th", function(th) {
      headers.push(th.innerHTML);
      th.style.display = "none";
    });

    queryForEach("tr", function(tr) {
      var i = 0;
      queryForEach("td", function(td) {
        if(!td.querySelector(".header")) {
          var header = headers[i];
          if (header.trim() === "&nbsp;") {
            td.classList.add("headerless");
          } else {
            td.innerHTML = "<span class='header'>" + header +
                           ":</span> " + td.innerHTML;
          }
        }
        i++;
      }, tr);
    }, table);
  };

  var removeHeadersFromTableCells = function(table) {
    queryForEach("th", function(th) {
      th.style.display = "";
    }, table);
    queryForEach("tr td .header", function(el) {
      while (el.firstChild) {
        el.removeChild(el.firstChild);
      }
      el.parentNode.removeChild(el);
    }, table);
    queryForEach("tr td", function(td) {
      td.classList.remove("headerless");
    }, table);
  };

  var responsiveTables = function() {
    queryForEach("article table", function(table) {
      if(getStyle(table, "display") === "block") {
        prependHeadersToTableCells(table);
      } else if(getStyle(table, "display") === "table") {
        removeHeadersFromTableCells(table);
      }
    });
  };
})(document, window);
