describe 'module: permission', ->

  beforeEach ->
    @permission = require 'module/permission'

  describe 'function: hasPermission', ->
    describe 'member', ->
      it 'should have access to member', ->
        expect(@permission.hasPermission('member', @permission.member)).toBe true

      it 'should not have access to admin', ->
        expect(@permission.hasPermission('member', @permission.admin)).toBe false

      it 'should not have access to owner', ->
        expect(@permission.hasPermission('member', @permission.owner)).toBe false

    describe 'admin', ->
      it 'should have access to member', ->
        expect(@permission.hasPermission('admin', @permission.member)).toBe true

      it 'should have access to admin', ->
        expect(@permission.hasPermission('admin', @permission.admin)).toBe true

      it 'should have access to owner', ->
        expect(@permission.hasPermission('admin', @permission.owner)).toBe true

    describe 'owner', ->
      it 'should have access to member', ->
        expect(@permission.hasPermission('owner', @permission.member)).toBe true

      it 'should have access to admin', ->
        expect(@permission.hasPermission('owner', @permission.admin)).toBe true

      it 'should have access to owner', ->
        expect(@permission.hasPermission('owner', @permission.owner)).toBe true

