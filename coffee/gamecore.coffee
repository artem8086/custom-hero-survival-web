import { EventEmmiter } from './events'
import { GameControl } from './gamecontrol'
import { ModelData, Model } from './model'
import { Player } from './player'
import { Arena } from './arena'
import { Animation } from './animation'
import { DrawStage } from './drawstage'
import { Engine } from './engine'
import { Loader } from './loader'

TEAM_NEUTRAL = 0
TEAM_PLAYERS = 1

class GameCore extends EventEmmiter

	cameraZoom: 0
	pauseTime: 0
	pause: false
	delta: 0

	constructor: (@canvas, @context, @mode = 'easy') ->
		super()
		@loader = new Loader
		@camera = camera = x: 0, y: 0, z: 0
		@gamescreen = $ '.gamescreen'
		@drawstage = new DrawStage @context, camera
		@mainArena = new Arena this
		@engine = new Engine this
		@mainPlayer = new Player this, TEAM_PLAYERS
		@gamecontrol = new GameControl this, @mainPlayer
		@time = Animation.getTime()

	load: ->
		@loadUnitsData()
		@mainArena.load @loader
		@loader.on 'load', =>
			@mainArena.init()
			@mainArena.set()
			@gamecontrol.init()
			@engine.init()
			@mainArena.createUnit 'banny', (unit) =>
				@mainPlayer.setMainUnit unit
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
				time = Animation.getTime() - @pauseTime
				@delta = time - @time
				@time = time

			@arena.update @time, @delta

			@mainPlayer.updateCamera()
			# context.translate cx, cy
			@arena.predraw()

			@drawstage.draw()

			@context.restore()
			# 
			window.requestAnimationFrame rndr
		rndr 0
		this

	pause: ->
		@engine.pause()
		@pause = true
		@delta = 0

	unpause: ->
		if @pause
			@engine.unpause()
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