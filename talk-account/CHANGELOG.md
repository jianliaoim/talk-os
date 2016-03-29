# 0.2.0

* 增加 Email 登录
* 新增索引
  * db.emails.ensureIndex({emailAddress: 1}, {unique: true, background: true})
  * db.emails.ensureIndex({user: 1}, {unique: true, background: true})

# 0.1.0

* 新增索引
  * db.mobiles.ensureIndex({phoneNumber: 1}, {unique: true, background: true})
  * db.mobiles.ensureIndex({user: 1}, {unique: true, background: true})
  * db.unions.ensureIndex({refer: 1, openId: 1}, {unique: true, background: true})
  * db.unions.ensureIndex({user: 1}, {background: true})
