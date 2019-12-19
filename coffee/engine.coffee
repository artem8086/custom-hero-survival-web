
UPDATE_TIME = 1000 / 20 # 20 times per second for game logic

class Engine

	pause: false

	constructor: (@gamecore) ->

	initEngine: ->
		@timer = setInterval(=>
			@logicUpdate
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
		


export { Engine }