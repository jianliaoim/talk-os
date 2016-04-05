## 2.10.0
* Feature: Add activity apis
* Feature: Add trello integration
* Feature: Add video typed message
* Feature: Add usage api for phone call
* Prepublish:
  * db.usagehistories.createIndex({team: 1, type: 1}, {background: true})

## 2.9.0
* Feature: Add reminder

## 2.8.0
* Feature: Add usage apis
* Prepublish:
  * db.usages.createIndex({team: 1, type: 1, month: 1}, {unique: true, background: true})

## 2.6.0
* Feature: Add activities
* Feature: Add monthly search index
* Prepublish:
  * Create search template
  * Reindex messages
  * db.activities.ensureIndex({team: 1, isPublic: 1, members: 1, _id: -1}, {background: true})
  * db.activities.ensureIndex({target: 1}, {background: true})

## 2.5.0
* Feature: Add story/mark, support jianliao 3.0
* Prepublish:
  * db.messages.ensureIndex({mark: 1, team: 1, _id: -1}, {background: true})
  * db.marks.ensureIndex({team: 1, target: 1, x: 1, y: 1}, {unique: true, background: true})
  * db.messages.ensureIndex({story: 1, _id: -1}, {background: true})
  * db.stories.ensureIndex({members: 1, team: 1, _id: -1}, {background: true})
  * db.notifications.ensureIndex({user: 1, team: 1, isHidden: 1, isPinned: 1, updatedAt: -1}, {background: true})
  * db.notifications.ensureIndex({target: 1, team: 1, user: 1, type: 1}, {unique: true, background: true})
  * db.notifications.ensureIndex({_emitterId: 1, team: 1}, {background: true})
  * Create story search mapping

## 2.1.0
* Prepublish:
  * mongoshell append-robot-service.js distinct-email-mobile.js migrate-account-user.js
  * db.users.ensureIndex({accountId: 1}, {unique: true, sparse: true, background: true})
  * db.users.ensureIndex({phoneForLogin: 1}, {unique: true, sparse: true, background: true})
  * db.users.ensureIndex({emailForLogin: 1}, {unique: true, sparse: true, background: true})
  * db.users.ensureIndex({service: 1}, {unique: true, sparse: true, background: true})
  * db.users.ensureIndex({'unions.refer': 1, 'unions.openId': 1}, {unique: true, sparse: true, background: true})
  * db.invitations.ensureIndex({team: 1}, {background: true})
  * db.invitations.ensureIndex({room: 1}, {background: true})
  * db.invitations.ensureIndex({key: 1, team: 1, room: 1}, {unique: true, background: true})
  * db.users.dropIndex('mobile_1')
  * db.users.dropIndex('sourceId_1_source_1')
  * db.users.dropIndex('email_1')

## New 2.0.0
* Feature: New message structure
* Prepublish:
  * db.messages.ensureIndex({'attachments.category': 1, team: 1, _id: -1, 'attachments.data.fileCategory': 1}, {background: true})
  * NODE_ENV=ga coffee scripts/migrate-messages.coffee
  * NODE_ENV=ga coffee scripts/create-mapping.coffee
  * NODE_ENV=ga coffee scripts/migrate-search.coffee

## 2.6.0
* Feature: Message tags
* Feature: Snippet
* Prepublish:
  * restart talk-schedule
  * UPDATE message search mapping
  * db.tags.ensureIndex({team: 1, name: 1}, {unique: true, background: true})
  * db.messages.ensureIndex({tags: 1, team: 1, _id: -1}, {background: true})

## 2.5.0
* Feature: Auto reply of talkai

## 2.4.1
* Feature: Add jenkins integration

## 2.4.0
* Feature: Add kf5, swathub integration

## 2.3.0
* Feature: Support dynamic domains
* Feature: Outgoing webhook

## 2.2.0
* Feature: Support for talk addons

## 2.1.0
* Feature: Add favorite apis
* Prepublish:
  * POST favorite search indexes
  * db.favorites.ensureIndex({favoritedBy: 1, message: 1}, {background: true, unique: true})
  * db.favorites.ensureIndex({favoritedBy: 1, team: 1, _id: -1}, {background: true})

## 2.0.0
* Feature: version 2.0

## 1.34.0
* Refactor: merge files collection to messages collection
* Prepublish:
  * set index db.messages.ensureIndex({'file._id': 1}, {background: true})
  * set index db.messages.ensureIndex({team: 1, 'file.fileCategory': 1, _id: -1}, {background: true})

## 1.33.0
* feature: new search api
* feature: use talk-services
* refactor: upgrade mongoose to 4.0.1
* prepublish:
  * execute search/reindex-messages.coffee script
  * execute db.files.update({isSpeech: null}, {$set: {isSpeech: false}}, {multi: true})

## 1.32.0
* feature: add room.prefs and team.prefs api
* feature: talkai will send message to the user not in the room when (s)he is mentioned
* refactor: increase the stability of code
* refactor: remove xss on string typed properties

## 1.31.1
* refactor: set unique index on devicetoken and member schema
* prepublish:
  * execute clear-repeat-devicetoken mongo shell
  * execute clear-repeat-member mongo shell
  * db.devicetokens.ensureIndex({token: 1, type: 1}, {unique: true, background: true})
  * db.members.ensureIndex({user: 1, room: 1, team: 1}, {unique: 1, background: true})

## 1.31
* refactor: set unique index on user and team schema
* prepublish:
  * execute clear-repeat-team mongo shell
  * db.users.dropIndex('sourceId_1')
  * set unique index on user schema: db.users.ensureIndex({sourceId: 1, source: 1}, {unique: true, sparse: true, background: true})
  * set unique index on team schema: db.teams.ensureIndex({sourceId: 1, source: 1}, {unique: true, sparse: true, background: true})

## 1.29
* refactor: use atomic operations in schema functions
* test:
    * 创建团队后，每个团队有一个公告板和一个小艾机器人
    * 修改消息后，显示“更新于 xxx 时间”
    * 正常更新 preference

## 1.28
* prepublish:
  * execute migrations
  * execute scripts/rebuild-room-rate.coffee
* feature: add hasVisited property on member schema
* feature: add popRate and memberCount on room schema

## 1.27
* feature: support rich text
* feature: add team name in push notifications

## 1.26
* feature: add text field on message
* refactor: save persistent data to mongodb

## 1.25
* feature: add incoming service
* feature: update nonJoinable property of team
* feature: add X-Client-Id for mobile usage
* feature: support xiaomi notification

## 1.24
* feature: coding, jinshuju service
* feature: pin the topics and member
* bugfix: keep the join state of member when syncing from other services

## 1.23
* feature: Private rooms
* refactor: Remove kits, integration blls. Add syncer, upgrade sundae

## 1.22
* feature: add some properties on message schema
* refactor: update limbo

## 1.17.0
* feature: notice apis for talk cms
* feature: set last read message id
* refactor: rewrite teambll and roombll

## 1.13.0
* feature: add github integration
* feature: option for only send notification when mention or direct message

## 1.12.2
* bugfix: fix team unread

## 1.11.0
* feature: star messages

## 1.9.6
* feature: add room pinyin

## 1.9.5
* refactor: some fix and readjust indexes

## 1.9.4
* feature: share from email, add page route

## 1.9.2
* feature: push notification to ios device
* feature: horizon search object
* refactor: remove some schemas of change code structure

## 1.9.0
* feature: remove integrations when archive room

## 1.8.2
* feature: create teambition source when create user
* feature: user have the `from` property

## 1.8.1
* feature: now support RSS 1.0

## 1.8.0
* feature: add pinyins field in user schema
* bugfix: fix rss encoding

## 1.7.1
* feature: add rss integration
* feature: add checkrss api

## 1.7.0
* feature: add pinyin in user schema
* feature: add title field in message.quote
* bugfix: fix initial-search script

## 1.5.2
* feature: add batchinvite api
* feature: upgrade lexer to 0.1.0
* bugfix: some fix on search api

## 1.5.0
* refactor: simulate socket client in test

## 1.3.4
* feature: add isSearchable field
* refactor: update sundae to 0.3.0
* refactor: upgrade limbo to 0.2.1

## 1.3.3
* refactor: upgrade limbo to 0.2.1

## 1.3.2
* refactor: change findOneAndUpdate to findOneAndSave
* bugfix: do not broadcast when robot is already a member of team/room

## 1.3.1
* bugfix: fix integration testcase
* refactor: rewrite socket object

## 1.3.0
* feature: add weibo integration
* feature: support for mobile device
* feature: support postMessage in landing api
* feature: use camo url

## 1.1.2
* feature: message.unread event
* feature: add unread on team list
* bugfix: fix unread counter between teams

## 0.4.36
* feature: change push service
* refactor: rename pm2 directory

## 0.4.35
* feature: update mail templates
* refactor: remove lib directory

## 0.4.34
* feature: message created by system is not editable
* feature: add team invite url
* feature: landing via inviteCode

## 0.4.33
* feature: clear unread messages when user quited from room
* feature: update/remove message
* feature: new room message
* refactor: rewrite permissions

## 0.4.32

* feature: add preference.language
* refactor: some refactor

## 0.4.31

* feature: send message when room updated
* refactor: remove _id in ensure params, update sundae to 0.2.1
* bugfix: prevent sending message to myself

## 0.4.30

* feature: sync user infomation between teambition and talk
* feature: create messages when update room infomation
* feature: add purpose to room
* feature: add team.setMemberRole api
* feature: set the default role of member as "member"
* bugfix: remove room member when quit from team

## 0.4.29

* bugfix: some fix

## 0.4.28

* feature: add executor in task schema add codeType in snippet
* feature: implement executor in task and codeType in snippet
* feature: filter task by executor id
* feature: add team.removeMember api
* feature: add attach count of team
* refactor: use snapper-node-client

## 0.4.27

* refactor: use sundae framework
* feature: add team.onlinestate api
* feature: do not send email to whom disabled email notification

## 0.4.26

* feature: change default message limit to 30
* refactor: move limbo initialize to config/database.coffee
* refactor: use supertest in test framework

## 0.4.25

* feature: change the display order of messages in mail

## 0.4.24

* feature: sync all organization member from teambition
* feature: force join the user to room or team by invitation
* feature: recommend friends will sync teambition member to talk
* refactor: remove integration.coffee; move all integration methods to integrations directory

## 0.4.23

* refactor: team/room invite response will include user infomation

## 0.4.22

* feature: add recommend.friends api

## 0.4.20

* refactor: add code structure in readme
* refactor: use helper to share method between controllers
* refactor: move message notify to message helper

## 0.4.19

* feature: send notification email when `@someone` in room
* refactor: use mixin in mail templates

## 0.4.18

* feature: join/leave team will automatic subscribe/unsubscribe the team channel
* refactor: rewrite constructor of Request/Response
* refactor: fix email align, remove useless mail templates
* bugfix: fix crash of update/read preference
* bugfix: fix room._teamId undefined crash

## 0.4.17

* refactor: add schema level indexes
* refactor: remove useless schemas

## 0.4.16

* bugfix: do not re-create invite object when email has already been invited
* refactor: update express middlewares
* refactor: update limbo and use method chain to call rpc methods

## 0.4.15

* refactor: move express configurations to express.coffee
* refactor: message broadcast methods
* refactor: remove duplicated code in test cases

## 0.4.14

* feature: integration will sync team and general room
* refactor: team bll
* bugfix: fix integration rejoin bug, auto join general room

## 0.4.13

* bugfix: fix sourceid in basicLogin, fix teambition team sync bug
* refactor: update [limbo](https://github.com/teambition/limbo) to 0.1.5

## 0.4.12

* refactor: replace panther with [limbo](https://github.com/teambition/limbo)
* refactor: move all db layer operations to bll

## 0.4.11

* feature: xss on task/file/snippet
* feature: add _latestRoomId to preference

## 0.4.10

* feature: add owner to team
* feature: move schemas to talk-core repos
* feature: email template now support task/file/snippet
* change: push message to self
* bugfix: cancel mailguy email

## 0.4.9

* feature: create task/file/snippet will also create message
* feature: if _roomId is not defined, the general room will be used
* feature: bind source and sourceId to user and team, remove source schema

## 0.4.8

* feature: upload task/file/snippet in message
* feature: apis for updating task/file/snippet
* feature: add source property in teams
* feature: user can not join the quited team
* feature: login with github
* feature: add user preference

## 0.4.7

* feature: direct invite team member to channel
* feature: intergration with teambition while read teams

## 0.4.5

* feature: use inline style in mail templates
* feature: edit user mobile

## 0.4.4

* feature: add a group of invite apis
* feature: add landing api to login with teambition account
* feature: add message notification mailer and invite mailer

## 0.4.3

* feature: move documents to `doc` branch
* feature: create general room when a team been created
* feature: when user leave a team, he also leave the rooms belong to the team
* feature: rename controller method to `action`
* feature: set the latestMessage limit to 10

## 0.4.2

* feature: add mailer support
* feature: add general validator for request params
* refactor: refactor bdd tests

## 0.4.0

* feature: change push service to [snapper](https://github.com/server/snapper)
* feature: upgrade express to 4.x
* feature: add team/source schemas
* feature: sync teambition organizations to teams
* feature: user can sign in with teambition account
* feature: a group of team apis
* feature: new message/room apis
* feature: add `to` option for router

## 0.3.0

* feature: update document to gitbook version

## 0.2.0

* feature: add `/v1/users/sync` api to sync user info from other websites.
* feature: use access token to call some api.
* feature: add `/v1/oauth/tracetoken` api to get the traced user's token or create the user.
* feature: add `/v1/discover` api to get the full api list
* remove robots, redesign later.

## 0.1.7

* feature: add `/v1/members/:_id` restful api and `member.readOne` robot api, for reading the member's infomation
* feature: add documents for using apis in robots <https://talk.ai/doc/#robot-step4-api>
* bugfix: untrimed message and name will cause an error in matches of `robot.respond`
* bugfix: the events in `robot.on` will start with ':', and only broadcast events will be looped to robots.
* some refactor
