import { Model } from './model'

MIN_Z_DISTANCE = -4000
MAX_Z_DISTANCE = 2000

class DrawStage

	constructor: (@context, @camera) ->
		@objects = []

	add: (model, v) ->
		objects = @objects
		v = v || x: 0, y: 0, z: 0
		if model.parts
			for _, part of model.parts
				unless part.hide
					p = new PartObject model, part
					p.v = v
					objects.push p

		if model.data.dirs
			unless model.nodeObj
				nObj = new NodeObject model
				nObj.v = v
				model.nodeObj = nObj
				objects.push nObj
		this

	addGroup: (drawgroup) ->
		@objects.push drawgroup
		this

	delete: (model) ->
		delete model.nodeObj
		@objects = @objects.filter (obj) ->
			obj.model != model
		this

	draw: ->
		cz = @camera.z
		@drawList = drawObjs = @objects
			.filter ((obj) ->
				z = obj.getZ() + cz
				z >= MIN_Z_DISTANCE && z <= MAX_Z_DISTANCE)
			.sort (a, b) ->
				a.getZ() - b.getZ()
		#
		for obj in drawObjs
			obj.draw this
		this

tVector = x: 0, y: 0, z: 0

class PartObject
	constructor: (@model, @part) ->

	setPos: (v) ->
		@v.x = v.x
		@v.y = v.y
		@v.z = v.z
		this

	getZ: ->
		@part.z + @v.z

	draw: (stage) ->
		c = stage.camera
		g = stage.context
		tVector.x = @v.x + c.x
		tVector.y = @v.y + c.y
		tVector.z = @v.z + c.z
		g.save()
		if @scale then g.scale @scale, @scale
		@model.drawPart g, @part, tVector, @opacity
		g.restore()

class NodeObject
	constructor: (@model) ->

	setPos: (v) ->
		@v.x = v.x
		@v.y = v.y
		@v.z = v.z
		this

	getZ: ->
		@v.z

	draw: (stage) ->
		c = stage.camera
		g = stage.context
		v = @v
		g.save()
		Model.transform(v.x, v.y, v.z, c)
			.apply g
		if @scale then g.scale @scale, @scale
		@model.drawNode g, @node, @opacity
		g.restore()

class DrawGroup extends DrawStage
	constructor: (@model, v) ->
		super()
		@v = v || x: 0, y: 0, z: 0

	setPos: (v) ->
		@v.x = v.x
		@v.y = v.y
		@v.z = v.z
		this

	getZ: ->
		@v.z

	draw: (stage) ->
		for obj in @objects
			vt = @v
			v = obj.v
			tx = v.x
			ty = v.y
			tz = v.z
			v.x += vt.x
			v.y += vt.y
			v.z += vt.z
			obj.draw stage
			v.x = tx
			v.y = ty
			v.z = tz
		this

	play: (time, target) ->
		result = true
		for obj in @objects
			res = obj.model.animation.play time
			if target == obj
				result = res
		result

	sort: ->
		@objects = @objects.sort (a, b) ->
			a.getZ() - b.getZ()
		this

export { DrawStage, DrawGroup }