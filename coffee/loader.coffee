import { EventEmmiter } from './events'

# Events:
# 'changepercent' trigger when some resorces loaded
# 'load' trigger when all resorces loaded

class Loader extends EventEmmiter
	loadResNumber = 0
	allResLoader = 0

	reset: () ->
		loadResNumber = allResLoader = 0

	getPercent: ->
		1 - if allResLoader != 0 then loadResNumber / allResLoader else 0

	updatePercent: () ->
		@trigger 'changepercent', [ @getPercent() ]

	load: (callback) ->
		_this = this
		loadResNumber++
		allResLoader++
		# @updatePercent()
		->
			callback?.apply _this, arguments
			loadResNumber--
			if loadResNumber <= 0
				_this.reset()
				_this.trigger 'load'
			_this.updatePercent()

	isLoad: ->
		loadResNumber <= 0

	loadJson: (file, callback) ->
		callback = @load callback
		$.getJSON file + '.json'
			.done callback
			.fail ->
				callback null

	loadJsonWithMode: (file, mode, callback) ->
		@loadJson file, (data1) ->
			@loadJson file + '_' + mode, (data2) ->
				if data1
					if data2
						Loader.combineConfigs data1, data2
					callback data1
				else
					callback data2

	loadImage: (file, callback) ->
		callback = @load callback
		img = new Image
		img.onload = ->
			callback img
		img.src = file
		img

	@combineConfigs: (obj1, obj2) ->
		for k, v of obj2
			switch typeof v
				when 'object'
					if v
						if v.constructor != Array
							obj = obj1[k]
							unless obj
								obj = obj1[k] = {}
							Loader.combineConfigs obj, v
						else
							obj1[k] = v
					else
						delete obj1[k]
				when 'undefined'
					delete obj1[v]
				else
					obj1[k] = v
		obj1

export { Loader }