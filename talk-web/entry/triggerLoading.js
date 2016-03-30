(function() {
  var sentences = window._initialStore.loadingSentences;
  document.getElementById('precept').textContent = sentences[(new Date()).getMinutes() % sentences.length];
})();
