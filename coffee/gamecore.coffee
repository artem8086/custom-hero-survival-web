import { EventEmmiter } from './events'
import { Arena } from './arena'
import { DrawStage } from './drawstage'
import { Loader } from './loader'

class GameCore extends EventEmmiter

	constructor: (@canvas, @context) ->
		super()
		@loader = new Loader
		@camera = camera = x: 0, y: 0, z: 0
		@drawstage = new DrawStage @context, camera
		@arena = new Arena

	load: ->
		@arena.load @loader
		@loader.on 'load', =>
			@arena.init()
			@arena.set this
			@trigger 'load'
		this

	render: ->
		rndr = (delta) =>
			@context.save()
			w = @canvas.width
			h = @canvas.height
			# cx = w / 2
			# cy = 0
			@context.fillStyle = '#fff'
			@context.fillRect 0, 0, w, h

			time = new Date().getTime() / 1000

			@arena.play time

			# context.translate cx, cy
			@arena.predraw this

			@drawstage.draw()

			@context.restore()
			# 
			window.requestAnimationFrame rndr
		rndr 0
		this

export { GameCore }