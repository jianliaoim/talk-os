# 重置密码

## 主要流程

1. 用户通过输入手机号或者邮箱地址，会首先得到一个手机验证码或者是邮件验证信息(验证码和验证链接)
2. 输入验证码或者点击验证链接以后会用户会是以'已登录'的角色进"密码重置"的页面

# 手机方式

1. 填写手机号，发送验证码。 `POST /v1/mobile/sendverifycode`
2. 验证手机验证码。 `POST /v1/mobile/signbyverifycode?verifyCode=xxxx&randomCode=dadDdadd`
3. 重新设置用户密码。`POST /v1/mobile/resetpassword?newPassword=xxxx&accountToken=fdafaf`

## 邮箱方式
1. 填写邮箱，通过邮件发送验证信息。 `POST /v1/email/sendverifycode`
2. 验证邮件中的验证信息。 `POST /v1/email/signbyverifycode?verifyCode=xxxx&randomCode=dadDdadd`
3. 重新设置用户密码。`POST /v1/email/resetpassword?newPassword=xxxx&accountToken=fdafaf`