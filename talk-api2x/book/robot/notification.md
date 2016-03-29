# How I receive a notification from a robot?

When user emit the `join.team` event (the event may be called each time you open the talk mobile application or refresh the talk web application), talk service will check if the user has read the notification from robot. The user will never recieve a notification unless he login talk.

Administrator of talk will create notice in the cms and set the schedule date. Whenever a user `join.team`, talk service check the `readNoticeAt` of user preference and pick up the notice scheduled between `readNoticeAt` and current time, then create a message from talkai to user in the team.

So the user will not recieve two same notification in the different teams. Hope this work for you.
