_           = require "underscore"
browserSync = require 'browser-sync'
ctags       = require 'gulp-ctags'
gulp        = require 'gulp'
nodemon     = require 'gulp-nodemon'
{exec}      = require 'child_process'
{log}       = require 'gulp-util'

# Browserify stuff
_          = require 'underscore'
browserify = require 'browserify'
buffer     = require 'vinyl-buffer'
coffee     = require 'gulp-coffee'
rename     = require "gulp-rename"
sass       = require "gulp-sass"
source     = require 'vinyl-source-stream'
sourcemaps = require 'gulp-sourcemaps'
uglify     = require "gulp-uglify"
watchify   = require 'watchify'

gulp.task 'dev-bundle', ->

	bundle = ->
		b.bundle()
		.on 'error', log
		.pipe source 'bundle.js'
		.pipe buffer()
		.pipe sourcemaps.init loadMaps: true, debug: true
		# .pipe uglify debug: true, options: sourceMap: true
		.pipe sourcemaps.write './'
		.pipe gulp.dest 'public/'

	opts =
		entries: ['client/main.coffee']
		debug: true
		cache: {},
		packageCache: {},
		plugin: [require "watchify"]
		extensions: ['.coffee']

	b = browserify opts
	b.transform require "coffeeify", {bare: true, header: false}
	b.transform require 'jadeify'
	b.on 'log', log
	b.on 'update', bundle
	bundle()

gulp.task 'compile-client', ->
	opts =
		entries: ['client/main.coffee']
		extensions: ['.coffee']

	prod_b = browserify opts
	prod_b.transform require "coffeeify", {bare: true, header: false}
	prod_b.transform require 'jadeify'
	prod_b.on 'log', log

	prod_b.bundle()
	.on 'error', log
	.pipe source 'bundle.js'
	.pipe buffer()
	# .pipe sourcemaps.init loadMaps: true, debug: true
	.pipe uglify()
	.pipe gulp.dest 'public/'

gulp.task 'sass', ->
	gulp.src "sass/**/*.sass"
	.pipe sourcemaps.init()
	.pipe sass().on "error", log
	.pipe sourcemaps.write '.'
	.pipe gulp.dest "./public/"
	.pipe browserSync.stream()

gulp.task 'default', ['sass', 'server', 'dev-bundle'], ->
	browserSync = browserSync.create()
	browserSync.init
		proxy:
			target: "localhost:3000"
		port: 8080

	gulp.watch 'sass/**/*.sass', ['sass']
	gulp.watch '**/*.coffee', ['coffee-tags']
	gulp.watch 'views/*.pug'
		.on 'change', browserSync.reload
	gulp.watch 'public/bundle.js'
		.on 'change', browserSync.reload

gulp.task 'prod-build', ['sass', 'compile-server', 'compile-client']

gulp.task 'compile-server', ->
	gulp.src './server/*.coffee'
	.pipe coffee bare: true
	.pipe gulp.dest './server'

gulp.task 'coffee-tags', ->
	exec 'coffeetags -R -f tags'

gulp.task 'coffee-lint', ->
	gulp.src ['client/**/*.coffee', 'server/**/*.coffee']
		.pipe coffeelint()
		.pipe coffeelint.reporter()

gulp.task 'server', ->
	stream = nodemon
		script: 'server/server.coffee'
		watch: ['server/*.coffee', 'lib/*.coffee']
		ext: 'coffee'
		env: 'NODE_ENV': 'development'

	stream
		# Force browser reload after server restart.
		.on 'start', -> setTimeout browserSync.reload, 1000
		.on 'crash', ->
			console.log 'Application crashed'
			stream.emit 'restart', 1
		.on 'restart', ->
			console.log 'Application restarted'
