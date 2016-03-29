# 群组
| 字段                 | 类型            | 出现的接口或推送事件 | 使用平台 | 描述                                      |
|----------------------|-----------------|----------------------|----------|-------------------------------------------|
| _creatorId           | ObjectId        | all                  | all      | 创建者ID                                  |
| _teamId              | ObjectId        | all                  | all      | 团队ID                                    |
| _id                  | ObjectId        | all                  | all      | room ID                                   |
| topic                | String          | all                  | all      | 话题                                      |
| members              | Array           | all                  | all      | 成员列表                           |
| purpose              | String          | all                  | all      | 话题目的                                  |
| isGeneral            | Boolean         | all                  | all      | 是否是"公告板"                            |
| isPrivate            | Boolean         | all                  | all      | 是否仅话题成员可见                        |
| color                | String          | all                  | all      | 话题背景色                                |
| email                | String          | all                  | all      | 发送邮件消息到话题中                       |
| isGuestVisible       | Boolean         | all                  | web      | 访客模式是否允许访客查看历史消息          |
| pinyin               | String          | all                  | all      | 话题中文对应的拼音                        |
| py                   | String          | all                  | all      | 话题中文对应的拼音的首字母                |
| memberCount          | Number          | all                  | all      | 描述room中member的个数                    |
| createdAt            | Date            | all                  | all      | room创建时间                              |
| updatedAt            | Date            | all                  | all      | room更新时间                              |
| prefs                | Object          | all                  | all      | 设置room中的isMute, alias, hideMobile属性 |
| isArchived           | Boolean         | create,archive       | all      | 是否已经归档                              |
| isGuestEnabled       | Boolean         | guest                | web      | 访客模式开启/关闭                         |
| guestToken           | String          | guest                | web      | 开启/关闭访客模式都会得到新的token值      |
| guestUrl             | String          | guest                | web      | 基于guestToken来生成的                    |
| isQuit               | Boolean         | leave                | all      | 是否已离开                            |
| joinDate             | Date            | guest/room/join      | web      | 访客加入时间                              |
| latestMessages       | Array           | join,read,create     | all      | 最近的30条信息                            |
| _latestReadMessageId | ObjectId        | join,read,create     | all      | 最近已读的信息                            |
| unread               | Object          | join,read,create     | all      | 未读消息的个数                            |
| pinnedAt             | Date            | team#pinTarget       | all      | 置顶的时间                                |
| isPinned             | Boolean         | team#pinTarget       | all      | 标示是否已被置顶                          |
| _memberIds           | Array(ObjectId) | team#rooms           | web      | room中所有的user的ID                      |
