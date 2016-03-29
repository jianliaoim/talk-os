# 消息/Message

| 字段                 | 类型     | 出现的接口或推送事件 | 使用平台 |描述                                                                            |
|----------------------|----------|----------------------|----------|---------------------------------------------------------------------------------|
| _creatorId           | ObjectId | all                  | all      | 创建者ID                                                                        |
| _teamId              | ObjectId | all                  | all      | 团队ID                                                                          |
| _roomId              | ObjectId | all                  | all      | 群组ID                                                                          |
| _storyId             | ObjectId | all                  | all      | 话题ID                                                                          |
| _toId                | ObjectId | all                  | all      | 用户ID                                                                          |
| body                 | String   | all                  | all      | 消息主体                                                                        |
| authorName           | String   | all                  | all      | 发送者名字                                                                      |
| authorAvatarUrl      | String   | all                  | all      | 发送者头像链接                                                                  |
| attachments          | Array    | all                  | all      | 附件(file, speech, rtf, quote, snippet)                                         |
| isSystem             | Boolean  | all                  | all      | 是否是系统消息                                                                  |
| icon                 | String   | join, leave          | all      | 系统消息提示图标                                                                |
| reservedType         | String   | create               | all      | 保留类别(目前只支持voice-call)                                                  |
| displayType          | String   | all                  | web      | 输入消息类型('text(默认)', 'markdown')                                          |
| createdAt             | Date     | all                  | all      | 创建时间                                                                        |
| updatedAt             | Date     | all                  | all      | 更新时间                                                                        |
| tags               | Array | all         | all      | 标签列表                                                                          |
