
class GameControl
	constructor: (@gamecore, @player) ->

	init: ->
		gamescreen = @gamecore.gamescreen
		gamescreen.on 'mousedown', (e) =>
			arena = 
			v = @gamecore.arena.pickFromScreen e.clientX, e.clientY
			@player.action =
				name: 'moveToPos'
				args: [v.x, v.y]

		# gamescreen.on 'wheel', (e) =>
		# 	delta = e.deltaY
		# 	console.log delta

		gamescreen.on 'drop', (e) =>
			arena = @gamecore.arena
			e.preventDefault()
			arena.createUnit 'banny', (unit) =>
				v = arena.pickFromScreen e.clientX, e.clientY
				unit.x = v.x
				unit.y = v.y
				@player.addUnit unit

		gamescreen.on 'dragover dragenter', -> false
		this

export { GameControl }