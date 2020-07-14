import { ModelData, Model } from './model'
import { EventEmmiter } from './events'
import { createGroup } from './groups'
import { AnimationData } from './animation'
import { DrawGroup } from './drawstage'
import { Loader } from './loader'
import { UnitState } from './unitstates'

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

class Unit extends EventEmmiter
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
		@drawgroup = drawgroup = new DrawGroup @model
		if @shadow
			drawgroup.add @shadow
			@shadow.nodeObj.node = @data.shadow.node
		drawgroup.add @model
		@model.nodeObj.node = @data.styles.default
		@arena.gamecore.drawstage.addGroup drawgroup
		this

	removeFromDraw: ->
		@arena.gamecore.drawstage.delete @model
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
		@state = new UnitState.UnitMove(this)
			.moveToPos x, y
		this

	stand: ->
		@state = null
		@setAnim 'stand'

	stop: ->
		@stand()

	setAngleV: (x, y) ->
		angle = Math.atan2(y, x) * 180 / Math.PI
		@model.setAngle angle
		@shadow.setAngle angle
		this

	update: (time, delta) ->
		# update unit state
		# unitStates[@state]?.call this
		@state?.update time, delta
		# check collisions with arena
		v = @arena.checkColission @x, @y
		if v
			@x = v.x
			@y = v.y
			@stop()
		# update model postion
		ground = @arena.ground
		drawgroup = @drawgroup
		v = drawgroup.v
		v.x = @x + ground.x
		v.z = @y + ground.z
		v.y = ground.y
		model = @model
		model.nodeObj.v.y = - @z
		# update animation
		unless drawgroup.play time, model
			@trigger 'anim_end'
		this

UnitGroup = createGroup Unit

export { Unit, UnitGroup, loadUnitData }