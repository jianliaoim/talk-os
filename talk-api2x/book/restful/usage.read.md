# usage.read

Read a list of usages

## Route
> GET /v2/usages

## Params
| key            | type               | required | description    |
| -------------- | ------------------ | -------- | -------------- |
| _teamId        | ObjectId           | true     | Team id        |

## Request
```json
GET /v2/usages?_teamId=536c99d0460682621f7ea6e5 HTTP/1.1
```

### Response
```json
[
  {
    "_id": "56b1bd92443d43a60a1cb31f",
    "team": "56b1bd9201326ed33642351f",
    "type": "userMessage",
    "__v": 0,
    "month": "2016-01-31T16:00:00.000Z",
    "maxAmount": -1,
    "amount": 0,
    "_teamId": "56b1bd9201326ed33642351f",
    "id": "56b1bd92443d43a60a1cb31f"
  },
  {
    "_id": "56b1bd92443d43a60a1cb31c",
    "team": "56b1bd9201326ed33642351f",
    "type": "inteMessage",
    "__v": 0,
    "month": "2016-01-31T16:00:00.000Z",
    "maxAmount": 10000,
    "amount": 0,
    "_teamId": "56b1bd9201326ed33642351f",
    "id": "56b1bd92443d43a60a1cb31c"
  },
  {
    "_id": "56b1bd92443d43a60a1cb31e",
    "team": "56b1bd9201326ed33642351f",
    "type": "file",
    "__v": 0,
    "month": "2016-01-31T16:00:00.000Z",
    "maxAmount": 209715200,
    "amount": 0,
    "_teamId": "56b1bd9201326ed33642351f",
    "id": "56b1bd92443d43a60a1cb31e"
  },
  {
    "_id": "56b1bd92443d43a60a1cb31d",
    "team": "56b1bd9201326ed33642351f",
    "type": "call",
    "__v": 0,
    "month": "2016-01-31T16:00:00.000Z",
    "maxAmount": 100,
    "amount": 0,
    "_teamId": "56b1bd9201326ed33642351f",
    "id": "56b1bd92443d43a60a1cb31d"
  }
]
```
