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


class Unit extends EventEmmiter
	x: 0
	y: 0
	z: 0

	constructor: (@data) ->
		super()
		@model = new Model
		@model.setData @data.models.default
		if @data.animation
			@model.animation.data = @data.animation.default
			@model.animation.setAnim @data.animations.stand
		if @data.shadow
			@shadow = new Model @data.shadow.model

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

	move: (x, y) ->
		this

	update: (time) ->
		ground = @arena.ground
		v = @model.nodeObj.v
		v.x = @x + ground.x
		v.z = @y + ground.z
		v.y = @z + ground.y
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