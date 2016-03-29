{limbo} = require '../components'

{
  SearchFavoriteModel
  FavoriteModel
} = limbo.use 'talk'

FavoriteSchema = FavoriteModel.schema

FavoriteSchema.pre 'save', (next) ->
  favorite = this
  favorite._wasNew = favorite.isNew
  next()

FavoriteSchema.post 'save', (favorite) ->
  if favorite._wasNew
    favorite.emit 'create', favorite
  else
    favorite.emit 'updated', favorite

FavoriteSchema.post 'create', (favorite) -> favorite.index()

FavoriteSchema.post 'updated', (favorite) -> favorite.index()

FavoriteSchema.post 'remove', (favorite) -> favorite.unIndex()
