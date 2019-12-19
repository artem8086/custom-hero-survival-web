import { EventEmmiter } from './events'
import { Unit, UnitGroup } from './unit'
import { createGroup } from './groups'


class Player extends EventEmmiter

	constructor: (@gamecore, @team) ->
		super()
		@selectUnits = new UnitGroup
		@playerUnits = new UnitGroup

	update: ->
		action = @action
		if action
			func = Unit::[action.name]
			@selectUnits.each (unit) =>
				if unit.owner == this
					func.apply unit, action.args
			@action = null
		this

	updateCamera: ->
		unit = @mainUnit
		if unit
			gamecore = @gamecore
			camOffs = gamecore.arena.cameraOffset
			ground = gamecore.arena.ground
			camera = gamecore.camera
			camera.x = ground.x + camOffs.x - unit.x
			camera.y = ground.y + camOffs.y - unit.z
			camera.z = ground.z + camOffs.z - unit.y + gamecore.cameraZoom

	addUnit: (unit) ->
		unit.owner = this
		@playerUnits.push unit
		this

	removeUnit: (unit) ->
		if unit.owner == this
			unit.owner = null
			index = @playerUnits.indexOf unit
			if index >= 0
				@playerUnits.splice index, 1
		this

	setMainUnit: (unit) ->
		@mainUnit = unit
		@addUnit unit
		@selectUnits = unit

	selectMain: ->
		if @mainUnit
			@selectUnits = @mainUnit
		else
			@selectUnits = new UnitGroup


PlayerGroup = createGroup Player

export { Player, PlayerGroup }