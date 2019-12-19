import { ModelData, Model } from './model'
import { EventEmmiter } from './events'
import { createGroup } from './groups'
import { AnimationData } from './animation'
import { Loader } from './loader'

loadUnitData = (unitData, callback, loader) ->
	if unitData.loader
		unitData.loader.on 'load', callback
		return null
	if unitData.isLoad
		callback()
	else
		loader ||= new Loader
		unitData.loader = loader
		if unitData.shadow
			unitData.shadow.model = ModelData.load loader, unitData.shadow.model
		models = unitData.models
		if models
			for name, model of models
				models[name] = ModelData.load loader, model

		animation = unitData.animation
		if animation
			for name, anim of animation
				animation[name] = AnimationData.load loader, anim

		load = ->
			delete unitData.loader
			unitData.isLoad = true
			callback()

		if loader.isLoad()
			load()
		else
			loader.on 'load', load
	null

UNIT_STAND = 0
UNIT_MOVE_TO_POSTION = 1

unitStates = []

unitStates[UNIT_MOVE_TO_POSTION] = ->
	v = @vPos
	xp = v.x - @x
	yp = v.y - @y
	mp = @data.moveRadius
	if xp * xp + yp * yp >= mp * mp
		@model.animation.scale = @data.speedScale * @getProp 'speed'
	else
		@stop()

class Unit extends EventEmmiter
	state: UNIT_STAND

	x: 0
	y: 0
	z: 0

	constructor: (@data) ->
		super()
		@model = new Model
		@model.setData @data.models.default
		if @data.animation
			anim = @model.animation
			anim.data = @data.animation.default
			@stand()
		if @data.shadow
			@shadow = new Model
			@shadow.setData @data.shadow.model
		@vPos = x: 0, y: 0
		@vMove = x: 0, y: 0
		@initProperties()

	initProperties: ->
		p = @props = {}
		for name, prop of @data.properties
			p[name] = v: prop, a: 0, m: 1

	getProp: (name) ->
		prop = @props[name]
		if prop
			prop.v * prop.m + prop.a
		else
			0

	add2draw: ->
		drawstage = @arena.gamecore.drawstage
		if @shadow
			drawstage.add @shadow
			@shadow.nodeObj.node = @data.shadow.node
		drawstage.add @model
		@model.nodeObj.node = @data.styles.default
		this

	removeFromDraw: ->
		if @shadow
			drawstage.delete @shadow
		drawstage = @arena.gamecore.drawstage
		drawstage.delete @model
		this

	setAnim: (name, scale = 1, isLoop = true) ->
		m = @model
		a = m.animation
		if @anim != name
			a.setAnim @data.animations[name], m.angle
			@anim = name
		a.scale = scale
		a.loop = isLoop
		this

	moveToPos: (x, y) ->
		@state = UNIT_MOVE_TO_POSTION
		@animation
		v = @vPos
		v.x = x
		v.y = y
		@setVecMove x - @x, y - @y
		m = @model
		@setAnim 'walk'
		this

	stand: ->
		@state = UNIT_STAND
		@setAnim 'stand'

	stop: ->
		@stand()
		v = @vMove
		v.x = v.y = 0

	setVecMove: (x, y) ->
		v = @vMove
		v.x = x
		v.y = y
		if x != 0 && y != 0
			@setAngleV x, y
			# normalize vector
			len = Math.sqrt x * x + y * y
			v.x /= len
			v.y /= len
		this

	setAngleV: (x, y) ->
		angle = Math.atan2(y, x) * 180 / Math.PI
		@model.setAngle angle
		@shadow.setAngle angle
		this

	update: (time, delta) ->
		# update movement
		v = @vMove
		x = v.x
		y = v.y
		if x != 0 && y !=0
			speed = delta * @getProp 'speed'
			@x += x * speed
			@y += y * speed
		# update unit state
		unitStates[@state]?.call this
		# check collisions with arena
		v = @arena.checkColission @x, @y
		if v
			@x = v.x
			@y = v.y
			@stop()
		# update model postion
		ground = @arena.ground
		v = @model.nodeObj.v
		v.x = @x + ground.x
		v.z = @y + ground.z
		v.y = ground.y - @z
		unless @model.animation.play time
			@trigger 'anim_end'
		if @shadow
			sv = @shadow.nodeObj.v
			sv.x = v.x
			sv.z = v.z
			sv.y = ground.y
			@shadow.animation.play time
		this

UnitGroup = createGroup Unit

export { Unit, UnitGroup, loadUnitData }