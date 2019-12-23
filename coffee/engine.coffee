
UPDATE_TIME = 1000 / 20 # 20 times per second for game logic

class Engine

	pause: false

	constructor: (@gamecore) ->

	init: ->
		@timer = setInterval(=>
			@logicUpdate()
		, UPDATE_TIME)

	pause: ->
		unless @pause
			@pause = true
			clearInterval @timer

	unpause: ->
		if @pause
			@pause = false
			@initEngine()

	logicUpdate: ->
		gamecore = @gamecore
		gamecore.mainPlayer.update()
		this


export { Engine }