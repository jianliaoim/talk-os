module.exports = {
  before: function (browser) {
    var jianliao = browser.page.jianliao();
    this.jianliao = jianliao;
    browser.login(jianliao);
  },

  after: function (browser) {
    browser.end();
  },

  '发送消息': function () {
    this.jianliao
      .sendMessage('测试机器我又回来拉');
  }


};
