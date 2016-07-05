module.exports = (grunt) ->

  # Project configuration.
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    coffee:
      src:
        options:
          bare: true
        files: [
          expand: true
          src: 'src/**/*.coffee'
          ext: '.js'
          dest: 'build'
        ,
          expand: true
          src: 'spec/**/*.coffee'
          ext: '.js'
          dest: 'build'
        ]

    clean:
      build:
        src: [
          'build/*'
        ]
      release:
        src: [
          'dist/*'
        ]

    copy:
      release:
        files: [
          expand: true
          cwd: 'build/src'
          src: '**/*.*'
          dest: 'dist'
        ]

    watch:
      options:
        spawn: false
      test:
        files: [
          'src/**/*.coffee'
          'spec/**/*.coffee'
        ]
        tasks: [
          'clean'
          'coffee'
        ]

    nodemon:
      # Start dev environment.
      dev:
        script: 'build/src'
        options:
          nodeArgs: ['--harmony'] # Support ES6 when node version < 4.0

  # These plugins provide necessary tasks.
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-nodemon'

  grunt.registerTask 'build', [
    'clean'
    'coffee'
    'watch'
  ]

  grunt.registerTask 'release', [
    'clean'
    'coffee'
    'copy'
  ]
