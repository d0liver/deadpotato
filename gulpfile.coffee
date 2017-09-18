# Node
path = require 'path'

# Gulp
gulp        = require 'gulp'
nodemon     = require 'gulp-nodemon'
{log}       = require 'gulp-util'

# Vinyl
buffer     = require 'vinyl-buffer'
source     = require 'vinyl-source-stream'

# Browserify stuff
browserify = require 'browserify'
coffee     = require 'gulp-coffee'
sass       = require "gulp-sass"
# Used with sass
sourcemaps = require 'gulp-sourcemaps'
uglify     = require "gulp-uglify"
watchify   = require 'watchify'

gulp.task 'dev-bundle', ->

	bundle = ->
		b.bundle()
		.on 'error', log
		.pipe source 'bundle.js'
		.pipe buffer()
		# XXX: Extract the source map (which will have been generated because
		# debug: true is given in the options below) out and put it in an
		# external file. It's important that these source maps are actually
		# extracted otherwise Watchify will not rebuild correctly (I believe
		# this is a bug with Watchify)
		.pipe sourcemaps.init loadMaps: true
		# Source maps are written relative to the destination given (which is
		# public/) so they will end up in public/bundle.js.map
		.pipe sourcemaps.write './'
		# .pipe uglify debug: true, options: sourceMap: true
		.pipe gulp.dest 'public/'

	opts =
		entries: ['client/main.coffee']
		debug: true
		cache: {}
		packageCache: {}
		plugin: [require 'watchify']
		extensions: ['.coffee']

	b = browserify opts
		.on 'log', log
		.on 'update', bundle
	bundle()

gulp.task 'compile-client', ->
	opts =
		entries: ['client/main.coffee']
		extensions: ['.coffee']

	prod_b = browserify opts
		.on 'log', log

	prod_b.bundle()
	.on 'error', log
	.pipe source 'bundle.js'
	.pipe buffer()
	# .pipe sourcemaps.init loadMaps: true, debug: true
	.pipe uglify()
	.pipe gulp.dest 'public/'

gulp.task 'sass', ->
	gulp.src 'sass/**/*.sass'
	.pipe sourcemaps.init()
	.pipe sass().on 'error', sass.logError
	.pipe sourcemaps.write '.'
	.pipe gulp.dest './public/'

gulp.task 'default', ['sass', 'server', 'dev-bundle'], ->

	gulp.watch 'sass/**/*.sass', ['sass']
	gulp.watch 'views/*.pug'
	gulp.watch 'public/bundle.js'

gulp.task 'prod-build', ['sass', 'compile-server', 'compile-client']

gulp.task 'compile-server', ->
	gulp.src './server/*.coffee'
	.pipe coffee bare: true
	.pipe gulp.dest './server'

gulp.task 'coffee-lint', ->
	gulp.src ['client/**/*.coffee', 'server/**/*.coffee']
		.pipe coffeelint()
		.pipe coffeelint.reporter()

gulp.task 'server', ->
	stream = nodemon
		script: 'server/server.coffee'
		# XXX: We don't ignore anything by default. Instead we just make sure
		# to only watch the things we're interested in.
		ignoreRoot: []
		watch: [
			'node_modules/gavel.js/**/*.coffee'
			'server/**/*.coffee'
			'lib/**/*.coffee'
		]
		ext: 'coffee'
		env: 'NODE_ENV': 'development'
