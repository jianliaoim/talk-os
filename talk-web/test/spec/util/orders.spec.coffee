Immutable = require 'immutable'

describe 'util: orders', ->

  beforeEach ->
    @orders = require 'util/orders'

  describe 'function: byRoleThenPinyin', ->
    it 'should sort by role', ->
      contact1 = Immutable.Map {_id: '1', role: 'owner'}
      contact2 = Immutable.Map {_id: '2', role: 'admin'}
      contact3 = Immutable.Map {_id: '3', role: 'member'}

      expect(@orders.byRoleThenPinyin(contact1, contact2)).toBe -1
      expect(@orders.byRoleThenPinyin(contact2, contact1)).toBe 1

      expect(@orders.byRoleThenPinyin(contact2, contact3)).toBe -1
      expect(@orders.byRoleThenPinyin(contact3, contact2)).toBe 1

      expect(@orders.byRoleThenPinyin(contact1, contact3)).toBe -1
      expect(@orders.byRoleThenPinyin(contact3, contact1)).toBe 1

      expect(@orders.byRoleThenPinyin(contact1, contact1)).toBe 0
      expect(@orders.byRoleThenPinyin(contact2, contact2)).toBe 0
      expect(@orders.byRoleThenPinyin(contact3, contact3)).toBe 0

  it 'should sort by role then by pinyin', ->
      contact1 = Immutable.Map {_id: '1', role: 'owner', pinyin: 'a'}
      contact2 = Immutable.Map {_id: '2', role: 'owner', pinyin: 'b'}

      expect(@orders.byRoleThenPinyin(contact1, contact2)).toBe -1
      expect(@orders.byRoleThenPinyin(contact2, contact1)).toBe 1
      expect(@orders.byRoleThenPinyin(contact1, contact1)).toBe 0
      expect(@orders.byRoleThenPinyin(contact2, contact2)).toBe 0

  describe 'function: member', ->
    it 'should move creator to top', ->
      creatorId = '1'

      byMember = @orders.byCreatorIdThenPinyin(creatorId)

      member1 = Immutable.Map {_id: '1', pinyin: 'a'}
      member2 = Immutable.Map {_id: '2', pinyin: 'z'}

      expect(byMember(member1, member2)).toBe -1
      expect(byMember(member2, member1)).toBe 1

    it 'shuold sort by creator than by pinyin', ->
      creatorId = '3'

      byMember = @orders.byCreatorIdThenPinyin(creatorId)

      member1 = Immutable.Map {_id: '1', pinyin: 'a'}
      member2 = Immutable.Map {_id: '2', pinyin: 'z'}

      expect(byMember(member1, member2)).toBe -1
      expect(byMember(member2, member1)).toBe 1
      expect(byMember(member1, member1)).toBe 0
      expect(byMember(member2, member2)).toBe 0

  describe 'function: byPinyin', ->
    it 'should compare pinyin', ->
      member1 = Immutable.Map {_id: '1', pinyin: 'a'}
      member2 = Immutable.Map {_id: '2', pinyin: 'z'}

      expect(@orders.byPinyin(member1, member2)).toBe -1
      expect(@orders.byPinyin(member2, member1)).toBe 1
      expect(@orders.byPinyin(member1, member1)).toBe 0
      expect(@orders.byPinyin(member2, member2)).toBe 0
