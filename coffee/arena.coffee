import { ModelData, Model } from './model'
import { Unit, UnitGroup } from './unit'


ARENA_FILE = 'arenas/arena'

class Arena
	constructor: (@gamecore) ->
		@units = new UnitGroup

	load: (loader, file) ->
		loader.loadJson file || ARENA_FILE, (data) =>
			if data
				for key, value of data
					this[key] = value

				if @model
					@modelData = ModelData.load loader, @model
	
	init: ->
		@arena = new Model
		@arena.setData @modelData

	predraw: ->
		canvas = @gamecore.canvas
		w = canvas.width
		h = canvas.height
		cx = (w / 2) + @translate.x
		cy = (h / 2) + @translate.y
		@gamecore.context.translate cx, cy

	set: ->
		@remove()
		@gamecore.drawstage.add @arena, @position
		ac = @camera
		if ac
			c = @gamecore.camera
			c.x = ac.x || 0
			c.y = ac.y || 0
			c.z = ac.z || 0

	remove: ->
		@gamecore.drawstage.delete @arena

	play: (time) ->
		@arena?.animation.play time
		@units.play time


export { Arena }