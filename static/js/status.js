$(function() {
  var $areaLatest = $('#area-latest'),
      $areaStats = $('#area-stats'),
      tmplLatest = Handlebars.compile($('#tmpl-latest').html()),
      tmplStats = Handlebars.compile($('#tmpl-stats').html());

  function updatePage() {
    $.getJSON('/stats', function(data) {
      $areaStats.html(tmplStats(data));
    });
    $.getJSON('/latest', function(data) {
      $areaLatest.html(tmplLatest({statuses: data}));
    });
  }

  setInterval(updatePage, 2000);
  updatePage();
});



