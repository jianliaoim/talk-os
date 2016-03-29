module.exports = {
  before: function (browser) {
    var jianliao = browser.page.jianliao();
    var login = 'cbswz123@gmail.com';
    var password = '123456'

    this.jianliao = jianliao;

    //　safari 退出不会删除session
    if (browser.options.desiredCapabilities.browserName === 'safari') {
      this.jianliao.navigate();
      return
    } else {
      this.jianliao.navigate()
        .waitForElementVisible('@signInButton')
        .click('@signInButton')
        .waitForElementVisible('@signInWithTeambition')
        .click('@signInWithTeambition')
        .waitForElementVisible('@emailInput')
        .setValue('@emailInput', login)
        .setValue('@passwordInput', password)
        .submitForm('@loginForm');
      }
  },

  after: function (browser) {
    browser.end();
  },

  '发送消息': function (browser) {
    this.jianliao
      .sendMessage('测试机器我又回来拉')
  },

  '添加链接': function (browser) {
    this.jianliao
      .waitForElementVisible('@startPageButton')
      .click('@startPageButton')
      .waitForElementVisible('@startPageLinkTabButton')
      .click('@startPageLinkTabButton')
      .assert.cssClassNotPresent('@startPageFooter', 'is-show')
      .waitForElementVisible('@storyCreateTitleInput')
      .setValue('@storyCreateTitleInput', ['www.medium.com', this.client.Keys.ENTER])
      .waitForElementVisible('@startPageSubmitButton')
      .assert.cssClassPresent('@startPageFooter', 'is-show')
      .click('@startPageSubmitButton', function () {
        browser.getLog('browser', function(logEntriesArray) {
          console.log(logEntriesArray);
        });
      })
      .waitForElementNotVisible('@startPageLinkTabButton')
      .sendMessage('成功添加链接')
      .waitForElementVisible('@startPageButton')
  }

  //'添加想法': function (browser) {
    //this.jianliao
      //.waitForElementVisible('@startPageButton')
      //.click('@startPageButton')
      //.waitForElementVisible('@startPageStoryTabButton')
      //.click('@startPageStoryTabButton')
      //.assert.cssClassNotPresent('@startPageFooter', 'is-show')
      //.waitForElementVisible('@storyCreateTitleInput')
      //.setValue('@storyCreateTitleInput', ['Create Story Title', this.client.Keys.ENTER])
      //.setValue('@storyCreateDescTextarea', ['Create Story Description', this.client.Keys.ENTER])
      //.waitForElementVisible('@startPageSubmitButton')
      //.assert.cssClassPresent('@startPageFooter', 'is-show')
      //.click('@startPageSubmitButton')
      //.waitForElementNotVisible('@startPageLinkTabButton')
      //.sendMessage('成功添加想法')
      //.waitForElementVisible('@startPageButton');
  //}

  //'发送emoji和@人': function (browser) {
    //this.jianliao
      //.waitForElementVisible('@messageArea')
      //.waitForElementVisible('@messageMentionButton')
      //.click('@messageMentionButton')
      //.waitForElementVisible('@messageMentionMenu')
      //.click('@messageMentionAll')
      //.waitForElementNotPresent('@messageMentionMenu')

      //.waitForElementVisible('@messageEmojiButton')
      //.click('@messageEmojiButton')
      //.waitForElementVisible('@messageEmojiMenu')
      //.click('@messageEmojiSmile')
      //.waitForElementNotPresent('@messageEmojiMenu')

      //.sendMessage('自动测试初号机 -> 发送@人和emoji')
      //.sendMessage('自动测试初号机 -> 连续发送消息1/5')
      //.sendMessage('自动测试初号机 -> 连续发送消息2/5')
      //.sendMessage('自动测试初号机 -> 连续发送消息3/5')
      //.sendMessage('自动测试初号机 -> 连续发送消息4/5')
      //.sendMessage('自动测试初号机 -> 连续发送消息5/5');
  //},

  //'pin notification': function (browser) {
    //this.jianliao
      //.waitForElementVisible('@secondNotification')
      //.click('@secondNotification')
      //.waitForElementVisible('@channelPinButton')
      //.click('@channelPinButton');
  //},

  //'mute notification': function (browser) {
    //this.jianliao
      //.waitForElementVisible('@secondNotification')
      //.click('@secondNotification')
      //.waitForElementVisible('@channelMuteButton')
      //.click('@channelMuteButton');
  //},

  //'remove notification': function (browser) {
    //this.jianliao
      //.moveToElement('@secondNotification', 0, 0)
      //.waitForElementVisible('@secondNotificationRemove')
      //.click('@secondNotificationRemove');
  //},

  //'添加话题': function (browser) {
    //this.jianliao
      //.waitForElementVisible('@startPageButton')
      //.click('@startPageButton')
      //.waitForElementVisible('@startPage')
      //.waitForElementVisible('@storyTopicAddButton')
      //.click('@storyTopicAddButton')

      //.waitForElementVisible('@storyCreateHeader')
      //.assert.cssClassPresent('@storyCreateButton', 'is-disabled')

      //.setValue('@storyTitleInput', 'Topic Title')
      //.assert.cssClassNotPresent('@storyCreateButton', 'is-disabled')
      //.setValue('@storyDescTextarea', 'Topic Description')
      //.assert.cssClassNotPresent('@storyCreateButton', 'is-disabled')

      //.click('@storyAddMemberButton')
      //.waitForElementVisible('@storyInviteModal')
      //.click('@storyInviteMember1')
      //.click('@storyInviteMember2')
      //.click('@storyInviteMember3')
      //.click('@storyInviteConfirmButton')
      //.waitForElementNotVisible('@storyInviteModal')
      //.click('@storyCreateButton')

      //.waitForElementVisible('@storyEditHeader')
      //.sendMessage('自动测试初号机 -> 添加话题');
  //},

  //'修改话题': function (browser) {
    //this.jianliao
      //.click('@storyTitleInput')
      //.waitForElementVisible('@storyCreateHeader')
      //.setValue('@storyTitleInput', '-> Edit Topic Title')
      //.setValue('@storyDescTextarea', '-> Edit Topic Description')
      //.click('@storyCloseHeaderButton')
      //.waitForElementVisible('@storyEditHeader');
  //},

  //'删除刚创建的story': function (browser) {
    //this.jianliao
      //.waitForElementVisible('@storyConfig')
      //.click('@storyConfig')
      //.waitForElementVisible('@storyRemoveButton')
      //.click('@storyRemoveButton');
  //},

  //'添加链接': function (browser) {
    //this.jianliao
      //.waitForElementVisible('@startPageButton')
      //.click('@startPageButton')
      //.waitForElementVisible('@startPage')
      //.waitForElementVisible('@storyLinkAddButton')
      //.click('@storyLinkAddButton')

      //.waitForElementVisible('@storyCreateHeader')
      //.assert.cssClassPresent('@storyCreateButton', 'is-disabled')
      //.assert.elementNotPresent('@storyTitleInput')
      //.assert.elementNotPresent('@storyDescTextarea')

      //.setValue('@storyLinkInput', 'www.medium.com')
      //.waitForElementVisible('@storyTitleInput')
      //.waitForElementVisible('@storyDescTextarea')
      //.assert.cssClassNotPresent('@storyCreateButton', 'is-disabled')
      //.assert.valueContains('@storyTitleInput', 'Medium')
      //.assert.valueContains('@storyDescTextarea', 'Medium')

      //.click('@storyAddMemberButton')
      //.waitForElementVisible('@storyInviteModal')
      //.click('@storyInviteMember1')
      //.click('@storyInviteMember2')
      //.click('@storyInviteMember3')
      //.click('@storyInviteConfirmButton')
      //.waitForElementNotVisible('@storyInviteModal')
      //.click('@storyCreateButton')

      //.waitForElementVisible('@storyEditHeader')
      //.sendMessage('自动测试初号机 | 添加链接 -> 发送消息');
  //},

  //'退出刚创建的story': function (browser) {
    //this.jianliao
      //.waitForElementVisible('@storyConfig')
      //.click('@storyConfig')
      //.waitForElementVisible('@storyQuitButton')
      //.click('@storyQuitButton');
  //},

  //'收藏消息': function (browser) {
    //this.jianliao
      ////.click('@firstNotification')
      //.waitForElementVisible('@lastMessage')
      //.moveToElement('@lastMessage', 0, 0)
      //.waitForElementVisible('@lastMessageDropDown')
      //.click('@lastMessageDropDown')
      //.waitForElementVisible('@lastMessageDropDownFav')
      //.click('@lastMessageDropDownFav');
  //}

};
