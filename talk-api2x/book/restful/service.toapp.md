## service.toapp

### summary
Redirect to the third-party application from room or private chat

### method
GET

### route
> /v2/services/toapp

### events

### params
| key            | type               | required | description                                                               |
| -------------- | ------------------ | -------- | ------------------------------------------------------------------------- |
| _teamId        | ObjectId           | true     | Team id                                                                   |
| url            | String             | true     | Redirect url                                                              |
| _toId          | ObjectId           | false    | Message to this user                                                      |
| _roomId        | ObjectId           | false    | Message to this room                                                      |

### request
```
GET /v2/services/toapp?_teamId=53915a822731262e14d806d5&_roomId=53915a822731262e14d806d2&url=http://somewhere.com HTTP/1.1
```

### response

Redirect to url
