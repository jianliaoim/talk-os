## preference.update

### summary
Update user preference

### method
PUT

### route
> /v2/preferences

### params
| key                | type               | required | description                                                               |
| ------------------ | ------------------ | -------- | ------------------------------------------------------------------------- |
| emailNotification  | Boolean            | false    | notification preference                                                   |
| _latestTeamId      | ObjectId           | false    | latest joined team id |
| hasShownTips       | Boolean            | false    | has shown tips          |
| language           | String             | false    | language                 |
| notifyOnRelated    | Boolean            | false    | Only send notification when mention or direct message          |
| displayMode        | Boolean            | false    | default/slim          |
| customOptions      | Object             | false    | Other customized options (needTalkAIReply, hasGetReply)         |
| muteWhenWebOnline  | Boolean            | false    | When this option is true, user will not receive push notification on mobile devices         |
| pushOnWorkTime  | Boolean            | false    | Only push notifications between 8:00 to 22:00 |
| timezone  | String            | false    | Current timezone       |

### request
```
PUT /v2/preferences HTTP/1.1
Content-Type: application/json
{
  "emailNotification": false,
  "desktopNotification": true
}
```

### response
```json
{
    "_id": "5397f47255cf5f554823b6c0",
    "user": "538d7a8eb0064cd263ea24cd",
    "emailNotification": false,
    "desktopNotification": true,
    "hasShownTips": false,
    "_latestTeamId": "538d7a8eb0064cd263ea24c8",
    "_latestRoomId": "538d7a8eb0064cd263ea24c9",
    "updatedAt": "2014-05-09T07:27:09.280Z",
    "createdAt": "2014-05-09T07:27:09.280Z",
    "customOptions": {
      "hasGetReply": false,
      "needTalkAIReply": true
    }
}
```
