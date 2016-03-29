## discover

### summary
get full api list

### method
GET

### route
> /v2/discover

### request
```
GET /v2/discover HTTP/1.1
```

### response
```
{
    "message.create": {
        "path": "/v2/messages",
        "method": "post"
    },
    "message.read": {
        "path": "/v2/messages",
        "method": "get"
    },
    "user.signin": {
        "path": "/v2/users/signin",
        "method": "post"
    },
    "user.readOne": {
        "path": "/v2/users/:_id",
        "method": "get"
    },
    "user.read": {
        "path": "/v2/users",
        "method": "get"
    },
    "user.create": {
        "path": "/v2/users",
        "method": "post"
    },
    "user.update": {
        "path": "/v2/users/:_id",
        "method": "put"
    },
    "team.join": {
        "path": "/v2/teams/:_id/join",
        "method": "post"
    },
    "team.subscribe": {
        "path": "/v2/teams/:_id/subscribe",
        "method": "post"
    },
    "team.create": {
        "path": "/v2/teams",
        "method": "post"
    },
    "team.read": {
        "path": "/v2/teams",
        "method": "get"
    },
    "team.readOne": {
        "path": "/v2/teams/:_id",
        "method": "get"
    },
    "room.join": {
        "path": "/v2/rooms/:_id/join",
        "method": "post"
    },
    "room.readOne": {
        "path": "/v2/rooms/:_id",
        "method": "get"
    },
    "room.read": {
        "path": "/v2/rooms",
        "method": "get"
    },
    "discover.index": {
        "path": "/v2/discover",
        "method": "get"
    }
}
```
