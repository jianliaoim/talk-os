# group.create

Create a group, user should be admin of the team

## Route
> POST /v2/groups

## Events

* [group:create](../event/group.create.html)

## Params
| key            | type               | required | description    |
| -------------- | ------------------ | -------- | -------------- |
| _teamId        | ObjectId           | true     | Team id        |
| name           | String             | true     | Group name        |
| _memberIds     | Array(ObjectId)    | false    | Participants of this group |

## Request
```json
POST /v2/groups HTTP/1.1
Content-Type: application/json
{
  "_teamId": "536c99d0460682621f7ea6e5",
  "name": "YYYY",
  "_memberIds": ["5603a5fe960c492df7c1a36a"]
}
```

### Response
```json
{
  "__v": 0,
  "creator": "5678c0a8dc8e39aa34a467a0",
  "team": "5678c0a8dc8e39aa34a467a2",
  "name": "XXX",
  "_id": "5678c0a9dc8e39aa34a467d4",
  "updatedAt": "2015-12-22T03:16:57.389Z",
  "createdAt": "2015-12-22T03:16:57.389Z",
  "members": [
    "5678c0a8dc8e39aa34a467a0"
  ],
  "_memberIds": [
    "5678c0a8dc8e39aa34a467a0"
  ],
  "_creatorId": "5678c0a8dc8e39aa34a467a0",
  "_teamId": "5678c0a8dc8e39aa34a467a2",
  "id": "5678c0a9dc8e39aa34a467d4"
}
```
