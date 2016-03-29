should = require 'should'
_ = require 'lodash'
Promise = require 'bluebird'
app = require '../app'
limbo = require 'limbo'
{prepare, cleanup} = app

{
  StoryModel
} = limbo.use 'talk'

describe 'Schemas#Story', ->

  it 'should create a story with file', (done) ->
    data =
      creator: '561ca7b4ea8b1ab77d6a1efe'
      fileKey: '1107ff00571d2cf89eebbd0ddabbdeb38fb0'
      fileName: 'ic_favorite_task.png'
      fileType: 'png'
      fileSize: 2986
      fileCategory: 'image'
      other: 'unnecessary property'

    story = new StoryModel
      category: 'file'
      data: data

    story.data.should.have.properties 'fileKey'
    story.should.not.have.properties 'other'
    story.data.downloadUrl.should.containEql data.fileKey

    # Update data properties
    _data = _.clone data
    _data.fileKey = '2107ff00571d2cf89eebbd0ddabbdeb38fb0'
    story.data = _data
    story.data.should.have.properties 'fileKey'
    story.data.downloadUrl.should.containEql _data.fileKey

    # Save story to database
    $story1 = story.$save()

    $story2 = $story1.then (story1) ->
      StoryModel.findOneAsync _id: story1._id
    .then (story2) ->
      story2.data.downloadUrl.should.containEql _data.fileKey
      story2.should.not.have.properties 'other'

    Promise.all [$story1, $story2]

    .nodeify done

  after cleanup
