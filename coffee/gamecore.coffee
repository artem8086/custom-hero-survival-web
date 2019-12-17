import { EventEmmiter } from './events'
import { Arena } from './arena'
import { Animation } from './animation'
import { DrawStage } from './drawstage'
import { Loader } from './loader'

class GameCore extends EventEmmiter

	constructor: (@canvas, @context, @mode = 'easy') ->
		super()
		@loader = new Loader
		@camera = camera = x: 0, y: 0, z: 0
		@drawstage = new DrawStage @context, camera
		@mainArena = new Arena this
		@pauseTime = 0
		@pause = false

	load: ->
		@loadUnitsData()
		@mainArena.load @loader
		@loader.on 'load', =>
			@mainArena.init()
			@mainArena.set()
			@mainArena.createUnit 'banny'
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

			unless @pause
				@time = Animation.getTime() - @pauseTime

			@arena.update @time

			# context.translate cx, cy
			@arena.predraw()

			@drawstage.draw()

			@context.restore()
			# 
			window.requestAnimationFrame rndr
		rndr 0
		this

	pause: ->
		@pause = true

	unpause: ->
		@pause = false
		@pauseTime += Animation.getTime() - @time

	loadUnitsData: ->
		@loader.loadJsonWithMode 'npc/units', @mode, (data) =>
			for name, unit of data
				if unit.extends
					exUnit = data[unit.extends]
					u = Loader.combineConfigs {}, exUnit
					u = Loader.combineConfigs u, unit
					data[name] = u
			@unitsData = data
		null

export { GameCore }