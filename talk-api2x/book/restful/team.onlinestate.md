## team.onlineState

### summary
read the online state of team members

### method
GET

### route
> /v2/teams/:_id/onlinestate

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
  <tbody>
    <tr>
      <td>_id</td>
      <td>String(ObjectId|InUrl)</td>
      <td>true</td>
      <td>team id</td>
    </tr>
  </tbody>
</table>

### request
```
GET /v2/teams/536c834d26faf71918b774ed/onlinestate HTTP/1.1
```

### response
```
{
  "53be411f48e9ce4c2b9621f1": 0,
  "53be41be138556909068769f": 1,
  "53bfb2e968f1db50348817b2": 0,
  "53c74385c9eb87da0a2e3dc9": 0,
  "53cc991a227a43f617969d97": 0,
  "53cc991a227a43f617969d98": 0,
  "53c490fc86c21d4b0c5635f9": 0,
  "53cc9987227a43f617969d9f": 0,
  "53ccb7315299bffe235df617": 0,
  "53ccb7735299bffe235df61b": 0,
  "53ccb8070a6d952f24d423f6": 0,
  "53ce0f6462af21fc5df74f1b": 0,
  "53ce11db62af21fc5df74f20": 0,
  "53ce131b62af21fc5df74f24": 0,
  "53cf76da9838ad478c95ca72": 0,
  "53cf89b19838ad478c95ca87": 0,
  "53cf8aea9838ad478c95ca8c": 0,
  "53cf91b39838ad478c95ca91": 0,
  "53cf92df9838ad478c95ca96": 0,
  "53d098c19d0edb000057faaf": 0,
  "53d0b8766e45cbf0c4dce521": 0,
  "53d0c16b660b64eb2c8298b2": 0,
  "53d0c2206e45cbf0c4dce536": 0,
  "53d1fcb4d2fbc300002112d9": 0,
  "53d20decd2fbc300002112f6": 0
}
```
