# usage.call

Save usage history of phone call

## Route
> POST /v2/usages/call

## Params
| key            | type               | required | description    |
| -------------- | ------------------ | -------- | -------------- |
| _teamId        | ObjectId           | true     | Team id        |
| callSids       | Array(String)      | true     | CallSids        |

## Request
```json
POST /v2/usages/call HTTP/1.1
{
  "_teamId": "536c99d0460682621f7ea6e5",
  "callSids": [
    "16031610490641240001030600108079",
    "1603161049064124000103060010807a"
  ]
}
```

### Response
```json
{
  "ok": 1
}
```
