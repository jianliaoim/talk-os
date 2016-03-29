## team.thirds

Read teams from third part applications

### Route
> GET /v2/teams/thirds

### Params
| key            | type               | required | description    |
| -------------- | ------------------ | -------- | --------------- |
| refer          | String             | true     | Reference of third-part application's name  |

### Request
```
GET /v2/teams/thirds?refer=teambition HTTP/1.1
```

### Response
```json
[
  {
    "name": "orgz1",
    "sourceId": "55f7d19c85efe377996a113f"
  },
  {
    "name": "orgz2",
    "sourceId": "55f7d19c85efe377996a114f"
  }
]
```
