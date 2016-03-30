var SEND_MESSAGE = true;

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
  url: 'http://dev.talk.ai',
  commands: [jianliaoCommands],
  elements: {
    // talk.ci/site
    signInButton: 'a[href="http://account.dev.talk.ai/signin"]',

    // account.talk.ci
    signInEmailInput: 'input[type=email]',
    signInPasswordInput: 'input[type=password]',
    signInSubmitButton: 'button.button.is-primary',


    // talk.ci web
    messageArea: '.message-editor .lite-textbox'
  }

};
