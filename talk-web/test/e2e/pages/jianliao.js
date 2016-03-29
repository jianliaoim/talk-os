var SEND_MESSAGE = false;

var jianliaoCommands = {
  sendMessage: function(message) {
    if (SEND_MESSAGE) {
      return this.waitForElementVisible('@messageArea')
        .setValue('@messageArea', [message, this.api.Keys.ENTER]);
    } else {
      return this;
    }
  }
};

module.exports = {
  url: 'http://talk.ci',
  commands: [jianliaoCommands],
  elements: {
    signInButton: '.login .btn-dim',
    signInWithTeambition: '.thirdparty-entries',
    emailInput: 'form.auth-form input[type=text]',
    passwordInput: 'form.auth-form input[type=password]',
    loginForm: 'form.auth-form',

    messageArea: '.message-editor .lite-textbox',

    messageMentionButton: '.message-controls .ti-at',
    messageMentionMenu: '.mention-menu',
    messageMentionAll: '.mention-menu .contact-name:first-child',

    messageEmojiButton: '.message-controls .ti-emoji',
    messageEmojiMenu: '.emoji-table',
    messageEmojiSmile: '.emoji-table .emoji-line:first-child .icon:first-child',

    //firstNotification: '.inbox-table ul li:first-child',
    //firstNotificationPinned: '.inbox-table ul li:first-child .pin.is-pinned',
    secondNotification: '.inbox-scroll ul li:nth-child(2)',
    //secondNotificationPin: '.inbox-table ul li:nth-child(2) .pin',
    secondNotificationRemove: '.inbox-scroll ul li:nth-child(2) .icon-remove',

    channelPinButton: '.channel-header .ti-pin',
    channelMuteButton: '.channel-header .ti-mute',

    startPageButton: '.team-toolbar .btn-launch',
    startPageFooter: '.launch-fullscreen .footer',
    startPageLinkTabButton: '.launch-fullscreen .btn-cell.green button',
    startPageStoryTabButton: '.launch-fullscreen .btn-cell.yellow button',
    startPageSubmitButton: '.launch-fullscreen .footer button.submit',

    storyCreateTitleInput: '.launch-tabpage .form-table input',
    storyCreateDescTextarea: '.launch-tabpage .form-table textarea',

    //startPage: '.start-page',
    //startPageInput: '.start-page .input-area input',

    //storyTopicAddButton: '.story-list .icon-sharp',
    //storyLinkAddButton: '.story-list .icon-link',

    //storyCreateHeader: '.channel-page .story-header.is-open',
    //storyEditHeader: '.channel-page .story-header.is-closed',

    //storyTitleInput: '.story-header .story-title input',
    //storyDescTextarea: '.story-header .story-desc textarea',

    //storyCreateButton: '.story-header .buttons .button.is-primary',
    //storyAddMemberButton: '.story-header .story-add-member .icon-plus',
    //storyCloseHeaderButton: '.story-header .footer .channel-resizer',

    //storyInviteModal: '.story-invite',
    //storyInviteMember1: '.story-invite .list .roster-item:first-child',
    //storyInviteMember2: '.story-invite .list .roster-item:nth-child(2)',
    //storyInviteMember3: '.story-invite .list .roster-item:nth-child(3)',
    //storyInviteConfirmButton: '.story-invite .bottom .button',

    //storyLinkInput: '.story-header .story-url input',

    //storyConfig: '.channel-action .icon-cog',
    //storyQuitButton: '.is-story-member .story-menu .item:first-child',
    //storyRemoveButton: '.is-story-member .story-menu .item:last-child',

    lastMessage: '.message-timeline > div:nth-last-child(2)',
    lastMessageDropDown: '.message-timeline > div:nth-last-child(2) .icon-chevron-down',
    lastMessageDropDownFav: '.message-timeline > div:nth-last-child(2) .side .menu .line:first-child'

  },


};
