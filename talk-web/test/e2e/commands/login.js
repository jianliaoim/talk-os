 var login = 'boshenc@gmail.com';
 var password = '123456';

exports.command = function (jianliao) {
  browser = this;
  //　safari 退出不会删除session
  if (browser.options.desiredCapabilities.browserName === 'safari') {
    return jianliao.navigate();
  } else {
    return jianliao.navigate()
      .waitForElementVisible('@signInButton')
      .click('@signInButton')
      .waitForElementVisible('@signInEmailInput')
      .click('@signInEmailInput')
      .setValue('@signInEmailInput', login)
      .setValue('@signInPasswordInput', password)
      .click('@signInSubmitButton');
  }
  return browser;
};
