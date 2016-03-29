logger = require 'graceful-logger'

settings =
  analysis:
    analyzer:
      ik:
        alias: ["ik_analyzer"]
        type: "org.elasticsearch.index.analysis.IkAnalyzerProvider"
      ik_smart:
        type: "ik"
        use_smart: true
      ik_max_word:
        type: "ik"
        use_smart: false

{limbo} = require '../server/components'

{
  SearchMessageModel
  SearchFavoriteModel
  SearchStoryModel
} = limbo.use 'talk'

SearchMessageModel.createMapping settings, -> logger.info "Create message mapping", arguments

SearchFavoriteModel.createMapping settings, -> logger.info "Create favorite mapping", arguments

SearchStoryModel.createMapping settings, -> logger.info "Create story mapping", arguments
