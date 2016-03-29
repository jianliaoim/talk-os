# 团队

| 字段            | 类型             | 出现的接口或推送事件             | 使用平台             | 描述            |
| --------------- | --------------- | ----------------------------- | ------------------- | --------------- |
| name            | String          | all                           | all                 | 团队名称         |
| _creatorId      | ObjectId        | all                           | all                 | 创建者 ID         |
| color           | String          | all                           | all                 | 团队主题色 |
| inviteCode      | String          | all                           | web                 | 团队邀请码，出现在下面 inviteUrl 中 |
| inviteUrl       | String          | all                           | web                 | 团队邀请链接，Web 端通过此链接加入团队 |
| source          | String          | 被同步的团队                   | web                 | 同步来源（teambition，github 等）|
| sourceId        | String          | 被同步的团队                   | web                 | 同步来源中的团队 ID |
| sourceName      | String          | 被同步的团队                   | web                 | 在同步来源中显示的名字 |
| sourceUrl       | String          | 被同步的团队                   | web                 | 在同步来源中显示的名字 |
| createdAt       | Date            | all                           | all                 | 创建时间         |
| hasVisited      | Boolean         | readOne,join                   | web                 | 当前用户是否已访问过团队 |
| unread          | Number          | readOne,join,read              | all           | 团队未读消息总数 |
| hasUnread       | Boolean         | readOne,read                  | all           | 是否有未读消息 |
| latestMessages  | Array           | readOne,join                   | all                       | 最近消息列表 |
| prefs           | Object          | readOne,join                  | all                       | 团队内首选项（别名，是否显示手机号等） |
| invitations     | Array          | readOne,join         | all                       | 被邀请成员列表 |
| members         | Array          | readOne,join         | all                       | 成员列表 |
| rooms           | Array          | readOne,join         | all                       | 群组列表 |
| signCode        | String          | readOne,join,refresh         | ios, android         | 邀请码 |
| signCodeExpireAt | Date          | readOne,join,refresh         | ios, android         | 邀请码有效期 |

