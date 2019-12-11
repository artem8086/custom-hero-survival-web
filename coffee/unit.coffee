import { EventEmmiter } from './events'
import { createGroup } from './groups'

class Unit extends EventEmmiter
	constructor: (@name) ->
		super()

	move: (x, y) ->
		console.log "move unit #{@name}"

	play: (time) ->

UnitGroup = createGroup Unit

export { Unit, UnitGroup }