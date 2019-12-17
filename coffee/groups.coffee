createGroup = (objectClass) ->
	class Group extends Array
		constructor: ->
			super 0

	getProperties = (obj, array = []) ->
		for prop in Object.getOwnPropertyNames obj
			if prop != 'constructor'
				func = obj[prop]
				if typeof func == 'function'
					array[prop] = func
		proto = Object.getPrototypeOf obj
		if proto.constructor != Object
			getProperties proto, array
		array

	proto = Group::

	for prop, func of getProperties objectClass::
		setProp = (func) ->
			proto[prop] = ->
				@forEach (e) ->
					func.apply e, arguments
		setProp func

	Group

export { createGroup }