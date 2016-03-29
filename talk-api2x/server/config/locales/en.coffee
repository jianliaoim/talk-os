module.exports =
  DEFAULT_ERROR: 'Undefined error'
  CREATE_ERROR: (collection) -> "Create data error : #{collection}"
  UPDATE_ERROR: (collection) -> "Update data error : #{collection}"
  DELETE_ERROR: (collection) -> "Delete data error :  #{collection}"

  NOT_LOGIN: 'You are not login yet. Please login into your account first.'
  INVALID_TOKEN: 'Token error，please log in again'
  MISSING_UID: 'UID missing'
  MEMBER_CHECK_FAIL: (type) -> "#{type or ''} member does not exist"
  SYNC_TEAMBITION_FAIL: (type = '') -> "Synchronize teambition #{type} error"

  # Privilege errors
  LANDING_FAIL: 'Log in error'
  SOCKET_ID_ERROR: 'Invalid socketId or session has expired'
  SOCKET_ID_BROKEN: 'Incomplete socketId data'
  CLIENT_ID_ERROR: 'Incorrect clientId'
  UNKNOWN_SYNC_SOURCE: 'Undefined synchronize resource'
  INVALID_APPLICATION: 'Application does not exist'
  PASSWORD_ERROR: 'Incorrect password or email'
  MISSING_INTEGRATION_SOURCE: (source = '') -> "Not found synchronize resource：#{source}"
  PROCESS_LOCKED: (key = '') -> "#{key} already be locked, please do not try again"
  TEAM_LEAVE_ERROR: "Failed to leave a team"
  ALREADY_MEMBER: "Member already exists"
  INVALID_INVITECODE: "Invalid invite code"
  INVALID_OBJECT: (args...) -> "Invalid object： #{args.join(', ')}"
  NO_PERMISSION: 'You are not authorized to access'
  TOKEN_EXPIRED: 'Your login session has expired. Please relogin and try again'
  NOT_EDITABLE: (fields...) -> "The following fields are not editable：#{fields.join(', ')}"
  ROOM_IS_ARCHIVED: "Topic is already archived"
  SIGNATURE_FAILED: "Signature validation failed"
  REQUEST_FAILD: "Request failed"
  NOT_ACCESSIBLE_FOR_GUEST: "Guest is not allowed to access"
  FILE_SAVE_FAILED: "Failed to save file"
  FILE_MISSING: "File missing"
  GUEST_MODE_DISABLED: 'Guest mode is already closed'
  PARAMS_OUT_OF_SIZE: (args...) -> "The length of parameter #{args} beyond the limits allowed"
  SEARCH_FAILED: 'Search request failed'
  OUT_OF_SEARCH_RANGE: 'Exceed search scope'
  RATE_LIMIT_EXCEEDED: 'Sending request too frequently'
  NOT_TEAMBITION_USER: "Not a Teambition user"
  NOT_PRIVATE_ROOM: "Deletion of member is forbidden in private room"
  INVALID_MSG_TOKEN: "Invalid message token"
  INVITATION_EXISTING: "Invitation record already exists"
  TOO_MANY_FIELDS: "The Number of parameter beyond the limits allowed"
  MEMBER_EXISTING: "Member already exist"
  VOIP_REQUEST_FAILD: (msg) -> "Failed to create voice account #{msg}"
  PROPERTY_EXISTING: (prop) -> "#{prop} attribute already exists"
  INVALID_ACCESS_TOKEN: "Incorrect access token"
  INVALID_OPERATION: (msg) -> "Operation not permitted：#{msg or ''}"
  INVALID_REFER: "Incorrect synchronize resource"
  PUSH_FAILED: "Push message failed %s"
  INVALID_MAKR_TARGET: "Object is not allowed to be marked"
  NAME_CONFLICT: "This name has been used."
  CAN_NOT_ADD_INTEGRATION_IN_OFFICIAL_ROOMS: "Sorry you can not add integrations in officail rooms"
  INTEGRATION_ERROR: "An error occured in your integration, please check your integration setting"
  INTEGRATION_ERROR_DISABLED: 'Your service has been disabled for some errors, please modify your configuration to reuse this integration. Error infomation: %s'
  MOBILE_RATE_EXCEEDED: "SMS send too many times"
  SEND_SMS_ERROR: 'Send sms error'
  BAD_REQUEST: "Bad request %s"

  # Common errors
  PARAMS_MISSING: (args...) -> "Parameter missing : #{args.join(', ')}"
  OBJECT_MISSING: (args...) -> "Object not found : #{args.join(', ')}"
  OBJECT_EXISTING: (args...) -> "Object already exist : #{args.join(', ')}"
  CLIENT_MISSING: (args...) -> "Client not found : #{args.join(', ')}"
  PARAMS_INVALID: (args...) -> "Invalid parameter : #{args.join(', ')}"
  INVALID_TARGET: (args...) -> "Incorrect target : #{args.join(', ')}"
  FIELD_MISSING: (args...) -> "Field missing : #{args.join(', ')}"
  PARAMS_CONFLICT: (args...) -> "Parameter conflict : #{args.join(', ')}"
  FUNCTION_MISSING: (args...) -> "Function missing : #{args.join(', ')}"
  CONFIG_MISSING: "Config file missing %s"

  # Application errors
  MESSAGE_NOT_EDITABLE: "Message is not editable"
  MESSAGE_STRUCTURE_ERROR: "Message structure error"
  INVALID_SERVICE: "Invalid third party integration"
  INVALID_RSS_URL: "Invalid RSS link"

  ########################## Define functions ##########################
  inteErrorMessage: (integration, topic = '') ->
    """
    The integration has an error, please check the configuration of integrations.
    Category: #{integration.category}.
    Error message: #{integration.errorInfo}.
    Topic: #{topic}.
    """
  mentionOutOfRoom: (creatorUser, room) ->
    util = require '../../util'
    [
      "#{creatorUser.prefs?.alias or creatorUser.name} mentioned you in topic "
      "<$link|#{util.buildTeamUrl room._teamId, room._id}|##{room.topic}$>"
    ].join ''

  inviteSMS: (inviterName, teamName, inviteLink) ->
    "#{inviterName} invite you to join #{teamName} team. Visit #{inviteLink} to sign up, and download Talk app to join the team. [Talk]"

  welcomeNewTeamMember: (team) ->
    msg = "Welcome to #{team.name}, you can share your files, ideas and links with your team members, and discuss in different channels. Let's talk."
    msg += "\n" + team.description if team.description?.length
    msg
