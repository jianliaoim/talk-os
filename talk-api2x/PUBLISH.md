* Remove index: `db.activities.dropIndex('team_1_isPublic_1_members_1__id_-1')`
* Create index: `db.activities.ensureIndex({team: 1, isPublic: 1, members: 1, createdAt: -1}, {background: true})`
