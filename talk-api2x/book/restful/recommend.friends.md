## recommend.friends

### summary
Get recommend friends

### method
GET

### route
> /v2/recommends/friends

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
  </tbody>
</table>

### request
```
GET /v2/recommends/friends HTTP/1.1
```

### response
```
[
  {
    "name": "陈涌",
    "email": "yong@teambition.com",
    "avatarUrl": "https://dn-st.qbox.me/user_default_avatars/1.png"
  },
  {
    "name": "zhi",
    "email": "zhi@teambition.com",
    "avatarUrl": "https://mailimg.teambition.com/logos/8.png"
  },
  {
    "name": "Lee qiang",
    "email": "qiang@teambition.com",
    "avatarUrl": "https://mailimg.teambition.com/logos/18.png",
    "_id": "539aa336be8fb2ac533aa08c"
  },
  {
    "name": "唐娟",
    "email": "juan@teambition.com",
    "avatarUrl": "https://dn-st.qbox.me/user_default_avatars/9.png",
    "_id": "5371bd46d844d72151dec271"
  }
]
```
