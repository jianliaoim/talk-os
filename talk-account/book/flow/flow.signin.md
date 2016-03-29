# 登录流程（必须处于登出状态）

## 主要流程

1. 应用（客户端或网页）访问 account.jianliao.com 接口通过以下登录方式获得 account 账号信息和 token，account 授权阶段结束。
2. 跳转简聊首页。

## 手机验证码

1. 填写手机号，发送验证码。 `POST /v1/mobile/sendverifycode`
2. 使用验证码登录。 `POST /v1/mobile/signin?verifyCode=xxxx&randomCode=dadDdadd`
3. 创建新账号或返回原账号信息。

## OAuth2 登录

### teambition
1. 跳转第三方网站 `GET /union/teambition`
2. 网页登录授权后跳转 `GET /union/callback/teambition?code=xxx`，移动端则是调用接口 `POST /v1/union/signin/teambition -d code=xxx`
3. 创建新账号或返回原账号信息，网页版跳转 next_url?token=xxx，移动端获得 accountToken

### github
1. 跳转到第三方网站 `GET /union/github`
2. 网页登录授权后跳转 `GET /union/callback/github?code=xxx`，移动端则是调用接口 `POST /v1/union/signin/github -d code=xxx`
3. 创建新账号或返回原账号信息，网页版跳转 next_url?token=xxx，移动端获得 accountToken

### weibo
1. 跳转到第三方网站 `GET /union/weibo`
2. 网页登录授权后跳转 `GET /union/callback/weibo?code=xxx`，移动端则是调用接口 `POST /v1/union/signin/weibo -d code=xxx`
3. 创建新账号或返回原账号信息，网页版跳转 next_url?token=xxx，移动端获得 accountToken

## OAuth1 登录

### trello
1. 跳转到第三方网站 `GET /union/trello`
2. 网页登录授权后跳转 `GET /union/callback/trello?oauth_token=xxx&oauth_verifier=xxx`，移动端则是调用接口 `POST /v1/union/signin/trello -d {oauth_token=xxx, oauth_verifier=xxx}`
3. 创建新账号或返回原账号信息，网页版由前端发送请求 `POST /union/signin/trello -d {oauth_token: "xxx", oauth_verifier: "xxx"}`，继而获得 accountToken; 而移动端基于前步获得 accountToken
