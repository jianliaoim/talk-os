# state

Read the state of talk

## Route
> GET /v2/state

## params
| key            | type               | required | description    |
| -------------- | ------------------ | -------- | -------------- |
| scope          | String             | false    | state scopes split by ',', e.g: scope=version,checkfornewnotice,unread |
| _teamId        | ObjectId           | false    | team id |

Scopes:

- `version` get current web application version
- `checkfornewnotice` check for new messages from talkai
- `unread` get unread number of team members
- `onlineweb` Check if web is online

## request
```json
GET /v2/state?_teamId=53be411f48e9ce4c2b9621f4&scope=version,onlineweb HTTP/1.1
```

## response
```json
{
  "version": "1.1.1",
  "onlineweb": 1
}
```
