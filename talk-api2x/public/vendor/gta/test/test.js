(function() {
  window.Gta.test = function () {
    window.Gta.pageview({
      'page': '/my-overridden-page?id=1',
      'title': 'my overridden page'
    });
    window.Gta.event('button', 'click', 'nav buttons', 4);
  }
  $('body').append('<button data-gta="event" data-label="clicked an appended button">click again</button>');
}())