mailers =
  'reset-password': require './reset-password'
  'verify': require './verify'

mailer = module.exports

mailer.getMailer = (template) -> mailers[template]
