
class GameControl
	constructor: (@gamecore, @player) ->

	init: ->
		gamescreen = @gamecore.gamescreen
		gamescreen.on 'mousedown', (e) =>
			arena = @gamecore.arena
			v = arena.pickCursor e.clientX, e.clientY
			v = arena.getGroundPoint v
			v.y = v.z
			v2 = arena.checkColission v.x, v.y
			if v2
				v = v2
			@player.action =
				name: 'moveToPos'
				args: [v.x, v.y]

		gamescreen.on 'wheel', (e) =>
			delta = e.deltaY
			console.log delta
		this

export { GameControl }