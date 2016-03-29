# 绑定流程（必须处于登录状态）

## 手机验证码

1. 填写手机号，发送验证码 `POST /v1/mobile/sendverifycode`
2. 填写验证码绑定当前账号 `POST /v1/mobile/bind?verifyCode=xxxx&randomCode=dadDdadd`
3. 如已被其他账号绑定，则返回错误信息和随机码 `bindCode`，可用于强制绑定到当前账号 `POST /v1/mobile/forcebind`
4. 如绑定成功则返回账号信息

## OAuth2 绑定

### teambition
1. 跳转第三方网站 `GET /union/teambition`
2. 网页登录授权后跳转 `GET /union/bind/teambition?code=xxx`，移动端则是调用接口 `POST /v1/union/bind/teambition -d code=xxx`
3. 如已被其他账号绑定，则返回错误信息和随机码 `bindCode`，可用于强制绑定到当前账号 `POST /v1/union/forcebind/teambition`
4. 如绑定成功则返回账号信息

### github
1. 跳转第三方网站 `GET /union/github`
2. 网页登录授权后跳转 `GET /union/bind/github?code=xxx`，移动端则是调用接口 `POST /v1/union/bind/github -d code=xxx`
3. 如已被其他账号绑定，则返回错误信息和随机码 `bindCode`，可用于强制绑定到当前账号 `POST /v1/union/forcebind/github`
4. 如绑定成功则返回账号信息

### weibo
1. 跳转第三方网站 `GET /union/weibo`
2. 网页登录授权后跳转 `GET /union/bind/weibo?code=xxx`，移动端则是调用接口 `POST /v1/union/bind/weibo -d code=xxx`
3. 如已被其他账号绑定，则返回错误信息和随机码 `bindCode`，可用于强制绑定到当前账号 `POST /v1/union/forcebind/weibo`
4. 如绑定成功则返回账号信息

## OAuth1 绑定

### trello
1. 跳转第三方网站 `GET /union/trello`
2. 网页登录授权后跳转 `GET /union/bind/trello?oauth_token=xxx&oauth_verifier=xxx`，移动端则是调用接口 `POST /v1/union/bind/trello -d {oauth_token=xxx&oauth_verifier=xxx}`
3. 如已被其他账号绑定，则返回错误信息和随机码 `bindCode`，可用于强制绑定到当前账号 `POST /v1/union/forcebind/trello`
4. 如绑定成功则返回账号信息