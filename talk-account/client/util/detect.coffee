
# Refer: http://emailregex.com/
emailRegExp = /^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$/i

mobileRegExp = /^[\+]?[\(]?\d*[\)]?[-. ]?\d*[-. ]?\d*[-. ]?\d*$/

exports.isEmail = (str) ->
  emailRegExp.test str

exports.isMobile = (str) ->
  mobileRegExp.test(str)

exports.isValidPassword = (str) ->
  str.length >= 6

exports.phoneNumber = (data, country) ->
  reg =
    switch country
      when 'cn' then /^\d{3}[-. ]?\d{4}[-. ]?\d{4}$/g
      when 'hk' then /^\d{4}[-. ]?\d{4}$/g
      when 'tw' then /^\d{3,4}[-. ]?\d{3}[-. ]?\d{3}$/g
      when 'jp' then /^\d{3,4}[-. ]?\d{4}[-. ]?\d{4}$/g
      when 'usa' then /^[\(]?\d{3}[\)]?[-. ]?\d{3}[-. ]?\d{4}$/g
      else /^[\+]?[\(]?\d*[\)]?[-. ]?\d*[-. ]?\d*[-. ]?\d*$/g
  reg.test data

# 检测是 QQ 邮箱时, 弹出对应的警告通知
qqEmailRegExp = /^.+@(qq|QQ)..+/i

exports.isQQEmail = (str) ->
  exports.isEmail(str) and
  qqEmailRegExp.test(str)
