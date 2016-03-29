# 动态

| 字段                 | 类型     | 出现的接口或推送事件 | 使用平台 | 描述                                                                            |
|----------------------|----------|----------------------|----------|---------------------------------------------------------------------------------|
| _creatorId           | ObjectId | all                  | all      | 创建者ID |
| _teamId              | ObjectId | all                  | all      | 团队ID |
| _targetId            | ObjectId | all                  | all      | 相关对象ID，可能为空 |
| type                 | String   | all                  | all      | 关联对象类型，room, story |
| text                 | String   | all                  | all      | 动态内容 |
| isPublic             | Boolean  | all                  | all      | 是否公开 |
| members              | Array    | all                  | all      | 相关成员，如果为公开，此字段为空数组 |
