module.exports = (grunt) ->
	grunt.initConfig
		mochaTest: 
			dev:
				options:
					reporter: 'nyan'
					require: 'LiveScript'
				src: 'test/tests/*.ls'
			minRun:
				options:
					reporter: 'min'
					require: 'LiveScript'
				src: 'test/tests/*.ls'
		watch:
			files: ['test/tests/*.ls', 'lib/*.ls', 'test/fixtures/*.ss', 'test/fixtures/*.ss.js']
			tasks: 'mochaTest:minRun'

	grunt.loadNpmTasks 'grunt-contrib-watch'
	grunt.loadNpmTasks 'grunt-mocha-test'

	grunt.registerTask 'test', 'mochaTest:dev'
	grunt.registerTask 'default', ['test', 'watch']