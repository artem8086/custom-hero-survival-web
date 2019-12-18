createGroup = (objectClass) ->
	class Group extends Array
		constructor: ->
			super 0

		each: Array::forEach

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

	objectClass::each = (callback) ->
		callback this

	for prop, func of getProperties objectClass::
		setProp = (func) ->
			proto[prop] = ->
				args = arguments
				@forEach (e) ->
					func.apply e, args
		setProp func

	Group

export { createGroup }