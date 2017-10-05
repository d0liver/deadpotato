class Logger

	log_levels =
		FATAL: 0
		WARN: 1
		NOTICE: 2
		DEBUG: 3

	if process.env.NODE_ENV is 'development'
		@_log_level = log_levels.DEBUG
	else
		@_log_level = log_levels.WARN

	Object.defineProperty @, 'LOG_LEVEL',
		get: -> return k for k,v of log_levels when v is @_log_level
		set: (str) -> @_log_level = log_levels[str]

	@_log = (args...) ->
			console.log args...

	@fatal = (args...) ->
		@_log args... if @_log_level >= FATAL

	@warn = (args...) ->
		@_log args... if @_log_level >= WARN

	@notice = (args...) ->
		@_log args... if @_log_level >= WARN

	@debug = ->
		@_log args... if @_log_level >= DEBUG

module.exports = Logger
