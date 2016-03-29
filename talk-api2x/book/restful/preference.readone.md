## preference.readOne

### summary
Get user preference

### method
GET

### route
> /v2/preferences

### params
<table>
  <thead>
    <tr>
      <th>key</th>
      <th>type</th>
      <th>required</th>
      <th>description</th>
    </tr>
  </thead>
</table>

### request
```
GET /v2/preferences HTTP/1.1
```

### response
```
{
    "_id": "5397f47255cf5f554823b6c0",
    "user": "538d7a8eb0064cd263ea24cd",
    "emailNotification": false,
    "desktopNotification": true,
    "hasShownTips": true,
    "_latestTeamId": "538d7a8eb0064cd263ea24c8",
    "_latestRoomId": "538d7a8eb0064cd263ea24c9",
    "updatedAt": "2014-05-09T07:27:09.280Z",
    "createdAt": "2014-05-09T07:27:09.280Z"
}
```
