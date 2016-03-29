module.exports = (grunt) ->
  grunt.initConfig
    coffee:
      default:
        options: {
          bare: true
          join: true
          sourceMap: false
        }
        files: {'lib/index.js': 'src/index.coffee'}

  grunt.loadNpmTasks('grunt-contrib-coffee')

  grunt.registerTask('default', ['coffee'])
