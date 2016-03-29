(function() {
  var date = new Date();
  var hash = date.getFullYear() + '/' + (date.getMonth() + 1) + '/' + date.getDate();
  var sentences = window._initialStore.loadingSentences[hash] || window._initialStore.loadingSentences['others'];
  document.getElementById('precept').textContent = sentences[date.getMinutes() % sentences.length];
})();
