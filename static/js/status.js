$(function() {
  var $areaLatest = $('#area-latest'),
      $areaStats = $('#area-stats'),
      tmplLatest = Handlebars.compile($('#tmpl-latest').html()),
      tmplStats = Handlebars.compile($('#tmpl-stats').html());

  function updatePage() {
    $.getJSON('/stats', function(data) {
      $.each(data.queries, function(i, q) {
        if (q.type === 'track') data.queries[i].is_track = true;
        if (q.type === 'follow') data.queries[i].is_follow = true;
      });
      $areaStats.html(tmplStats(data));
    });
    $.getJSON('/latest', function(data) {
      $areaLatest.html(tmplLatest({statuses: data}));
    });
  }

  setInterval(updatePage, 2000);
  updatePage();
});



