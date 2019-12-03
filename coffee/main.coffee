import { ModelData, Model } from './model'
import { AnimationData } from './animation'
import { Loader } from './loader'

$(document).ready ->
	$canvas = $ '#canvas'
	canvas = $canvas.get 0
	context = canvas.getContext '2d', alpha: false

	modelFile = 'models/arena'
	loader = new Loader
	model = new Model
	modelData = new ModelData
	animationFrame = null
	camera =
		canvas: canvas
		g: context
		x: 0
		y: 0
		z: 0

	resize = ->
		canvas.width = $(window).width()
		canvas.height = $(window).height()

	resize()

	$(window).on 'resize', resize

	modelRefresh = ->
#		for key, _ of modelData
#			delete modelData[key]
		modelData.load loader, modelFile
	
	loader.on 'load', ->
		model.setData modelData
		if model.animation.data
			# model.animation.setAnim 'test', 0
			#
			model.animation.setAnim animationFrame, model.angle

	modelRefresh()

	render = (delta) ->
		context.save()
		w = canvas.width
		h = canvas.height
		cx = w / 2
		cy = 0
		context.fillStyle = '#fff'
		context.fillRect 0, 0, w, h
		context.beginPath()
		context.lineWidth = 2
		context.strokeStyle = '#f00'
		context.moveTo cx, 0
		context.lineTo cx, h
		context.moveTo 0, cy
		context.lineTo w, cy
		context.stroke()

		context.translate cx, cy

		model.animation.play()

		model.drawParts context, camera

		Model.transform(0, 0, 0, camera)
			.apply context

		model.draw2D context

		context.restore()
		# 
		window.requestAnimationFrame render

	render(0)

	oldMouseX = oldMouseY =0
	moveCamera = (e) ->
		camera.x += e.clientX - oldMouseX
		camera.y += e.clientY - oldMouseY
		oldMouseX = e.clientX
		oldMouseY = e.clientY

	$canvas.on 'mousedown', (e) ->
		oldMouseX = e.clientX
		oldMouseY = e.clientY
		$canvas.on 'mousemove', moveCamera

	$canvas.on 'touchstart', (e) ->
		oldMouseX = e.touches[0].clientX
		oldMouseY = e.touches[0].clientY

	$canvas.on 'touchmove', (e) ->
		moveCamera e.touches[0]

	$canvas.on 'mouseup', ->
		$canvas.off 'mousemove', moveCamera

	launchFullScreen document.documentElement

	launchFullScreen = (element) ->
		if element.requestFullScreen
			element.requestFullScreen()
		else if element.mozRequestFullScreen
			element.mozRequestFullScreen()
		else if element.webkitRequestFullScreen
			element.webkitRequestFullScreen()

	cancelFullscreen = ->
		if document.cancelFullScreen
			document.cancelFullScreen()
		else if document.mozCancelFullScreen
			document.mozCancelFullScreen()
		else if document.webkitCancelFullScreen
			document.webkitCancelFullScreen()