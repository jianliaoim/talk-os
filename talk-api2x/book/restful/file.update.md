## file.update

### summary
update file

### method
put

### route
> /v2/files/:_id

### event
* [file:update](../event/file.update.html)

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
      <td>file id</td>
    </tr>
    <tr>
      <td>fileKey</td>
      <td>String</td>
      <td>false</td>
      <td>file key</td>
    </tr>
    <tr>
      <td>fileName</td>
      <td>String</td>
      <td>false</td>
      <td>file name</td>
    </tr>
    <tr>
      <td>fileType</td>
      <td>String</td>
      <td>false</td>
      <td>file type</td>
    </tr>
    <tr>
      <td>fileSize</td>
      <td>Number</td>
      <td>false</td>
      <td>file size</td>
    </tr>
    <tr>
      <td>fileCategory</td>
      <td>String</td>
      <td>false</td>
      <td>file category</td>
    </tr>
    <tr>
      <td>imageWidth</td>
      <td>Number</td>
      <td>false</td>
      <td>image width</td>
    </tr>
    <tr>
      <td>imageHeight</td>
      <td>Number</td>
      <td>false</td>
      <td>image height</td>
    </tr>
  </tbody>
</table>

### request
```
PUT /v2/files/539936f1c3bc0c47175f468c HTTP/1.1
{
  "fileName": "2.png",
  "fileKey": "2dda216c6095750ec4840925a14ebad1",
  "fileType": "png"
}
```

### response
```json
{
    "__v": 0,
    "fileName": "2.png",
    "fileKey": "2dda216c6095750ec4840925a14ebad1",
    "fileType": "png",
    "creator": "538d7a8eb0064cd263ea24cd",
    "team": "538d7a8eb0064cd263ea24ca",
    "createdAt": "2014-06-12T05:13:21.179Z",
    "updatedAt": "2014-06-12T05:13:21.179Z",
    "_id": "539936f1c3bc0c47175f468c",
    "_creatorId": "538d7a8eb0064cd263ea24cd",
    "_teamId": "538d7a8eb0064cd263ea24ca",
    "thumbnailUrl": "http://striker.project.ci/thumbnail/2d/da/216c6095750ec4840925a14ebad1.png/w/500/h/500",
    "downloadUrl": "http://striker.project.ci/uploads/2d/da/216c6095750ec4840925a14ebad1.png?download=2.png&e=1402553601&sign=8af4d8fc95330570180d923d9d7192a8a18c8faf:3P6vmsdrK4C81879fisQpYaoX9Y=",
    "id": "539936f1c3bc0c47175f468c"
}
```
