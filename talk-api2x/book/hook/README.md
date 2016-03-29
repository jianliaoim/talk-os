# hooks

## How hooks used in the Matrix of talk

`Jarvis` is a A.I. robot of talk which running in an independent environment, when user create a team, Matrix automatic invite `Jarvis` to the team as a special member. Then Matrix will create a hook between `Jarvis` and the Matrix himself.

```
{
  "clientId": "98f36563-99cf-4cdb-b2e6-8e5c1cf3c080"
  "url": "https://jarvis.talk.ai"
  "events": ["message.create"]
  "isActive": true
  "config": {}
}
```

Now when use send messages to `Jarvis` in this team, He will immediately get a 'message.create' event sent from Matrix, so he'll know what have happened with user.

```
{
  "event": "message.create"
  "message": {
    "__v": 0,
    "creator": "538d7a8eb0064cd263ea24cd",
    "room": "538d7d6d255600da6286865b",
    "team": "538d7a8eb0064cd263ea24ca",
    "content": "hello world",
    "createdAt": "2014-06-12T05:00:51.654Z",
    "updatedAt": "2014-06-12T05:00:51.654Z",
    "_id": "53993403c3bc0c47175f468a",
    "_teamId": "538d7a8eb0064cd263ea24ca",
    "_roomId": "538d7d6d255600da6286865b",
    "_creatorId": "538d7a8eb0064cd263ea24cd",
    "id": "53993403c3bc0c47175f468a"
  }
}
```

`Jarvis` will deal with the left things

## Principles

- hooks can only edit by users, not the third party applications
