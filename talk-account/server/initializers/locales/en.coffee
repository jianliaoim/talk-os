module.exports =
  NOT_FOUND: 'Not Found'
  OBJECT_MISSING: (msg = '') -> "Object missing #{msg}"
  PARAMS_INVALID: (msg = '') -> "Invalid parameter #{msg}"
  PARAMS_MISSING: (msg = '') -> "Parameter #{msg} missing"
  RATE_LIMIT_EXCEEDED: "Sending request too freqently"

  REQUEST_FAILED: 'Request failed'
  VERIFY_FAILED: 'Verify failed'
  ACCESS_FAILED: 'No permission to access'
  RESEND_TOO_OFTEN: 'Request too frequently'
  INVALID_SOURCE: (source) -> "#{source} not yet supported"
  LOGIN_FAILED: "Login failed ：%s"
  BIND_CONFLICT: "Specified binding account already occupied"
  PASSWORD_TOO_SIMPLE: "Password is too simple, please change!"
  LOGIN_VERIFY_FAILED: 'There was an error with your E-Mail/Password or Phone/Password combination. Please try again.'
  ACCOUNT_EXISTS: 'Specified account already exists'
  INVALID_ACTION: 'Invalid action parameter'
  ACCOUNT_NOT_EXIST: 'Account does not exist'
  SEND_SMS_ERROR: 'Error sending SMS'
  NO_PASSWORD: "Specified account have no password. Please set up password to login in."
