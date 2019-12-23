import { ModelData, Model } from './model'
import { AnimationData } from './animation'
import { Selection } from './selection'
import { Unit, UnitGroup } from './unit'
import { loadUnitData } from './unit'

ARENA_FILE = 'arenas/arena'

curObj = x: 0, y: 0, z: 0

class Arena extends Selection
	constructor: (@gamecore) ->
		super()
		@units = new UnitGroup

	load: (loader, file) ->
		loader.loadJson file || ARENA_FILE, (data) =>
			if data
				for key, value of data
					this[key] = value

				if @model
					@modelData = ModelData.load loader, @model

				if @animation
					@animData = AnimationData.load loader, @animation.file
	
	init: ->
		@arena = new Model
		@arena.setData @modelData
		if @animData
			@arena.animation.data = @animData
			@arena.animation.setAnim @animation.default
		this

	predraw: ->
		canvas = @gamecore.canvas
		w = canvas.width
		h = canvas.height
		cx = (w / 2) + @translate.x
		cy = (h / 2) + @translate.y
		@gamecore.context.translate cx, cy
		this

	pickCursor: (x, y) ->
		canvas = @gamecore.canvas
		w = canvas.width
		h = canvas.height
		x -= (w / 2) + @translate.x
		y -= (h / 2) + @translate.y
		camera = @gamecore.camera
		v = Model.untransform x, y, camera
		curObj.x = v.x
		curObj.y = v.y
		curObj.z = v.z
		curObj

	getGroundPoint: (v) ->
		ground = @ground
		v.x -= ground.x
		v.x -= ground.y
		v.z -= ground.z
		v

	createUnit: (name, callback) ->
		data = @gamecore.unitsData[name]
		if data
			loadUnitData data, =>
				unit = new Unit data
				@add unit
				callback?(unit)
		this

	add: (unit) ->
		unit.arena = this
		@units.push unit
		if @gamecore.arena == this
			unit.add2draw()
		this

	remove: (unit) ->
		index = @units.indexOf unit
		if index >= 0
			@units.splice index, 1

	set: ->
		@remove()
		@gamecore.arena = this
		@gamecore.drawstage.add @arena, @position
		@units.add2draw()
		ac = @camera
		if ac
			c = @gamecore.camera
			c.x = ac.x || 0
			c.y = ac.y || 0
			c.z = ac.z || 0

	remove: ->
		@gamecore.arena = null
		@gamecore.drawstage.delete @arena
		@units.removeFromDraw()

	update: (time, delta) ->
		@arena?.animation.play time
		@units.update time, delta
	
	checkColission: (x, y) ->
		collide = false
		for col in @collisions
			if x < col.x1
				x = col.x1
				collide = true
			if x > col.x2
				x = col.x2
				collide = true
			if y < col.y1
				y = col.y1
				collide = true
			if y > col.y2
				y = col.y2
				collide = true
		if collide
			curObj.x = x
			curObj.y = y
			curObj
		else
			null

export { Arena }