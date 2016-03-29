xss = require 'xss'

module.exports = util =
  stripHtml: (html) ->
    return html unless html and toString.call(html) is '[object String]'
    xss html,
      whiteList: []
      stripIgnoreTag: true
      stripIgnoreTagBody: ['script', 'style']
  ###*
   * Only keep the html between body tags
   * @param  {String} html content
   * @return {String} content between bodys
  ###
  extractBodyContent: (html = '') ->
    matches = html.match /<body[^>]*>((.|[\n\r])*)<\/body>/im
    return matches?[1] or html
