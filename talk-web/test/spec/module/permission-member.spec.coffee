describe 'module: permission member', ->

  beforeEach ->
    @permission = require 'module/permission-member'

  describe 'function: hasPermission', ->
    describe 'member', ->
      it 'can not control member', ->
        expect(@permission.hasPermission('member', 'member')).toBe false

      it 'can not control admin', ->
        expect(@permission.hasPermission('member', 'admin')).toBe false

      it 'can not control owner', ->
        expect(@permission.hasPermission('member', 'owner')).toBe false

    describe 'admin', ->
      it 'can control member', ->
        expect(@permission.hasPermission('admin', 'member')).toBe true

      it 'can not control admin', ->
        expect(@permission.hasPermission('admin', 'admin')).toBe false

      it 'can not control owner', ->
        expect(@permission.hasPermission('admin', 'owner')).toBe false

    describe 'owner', ->
      it 'can control member', ->
        expect(@permission.hasPermission('owner', 'member')).toBe true

      it 'can control admin', ->
        expect(@permission.hasPermission('owner', 'admin')).toBe true

      it 'can not control owner', ->
        expect(@permission.hasPermission('owner', 'owner')).toBe false

