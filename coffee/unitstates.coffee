class UnitMove
	constructor: (@unit) ->
		@vPos = x: 0, y: 0
		@vMove = x: 0, y: 0

	setVecMove: (x, y) ->
		v = @vMove
		v.x = x
		v.y = y
		if x != 0 || y != 0
			@unit.setAngleV x, y
			# normalize vector
			len = Math.sqrt x * x + y * y
			v.x /= len
			v.y /= len
		this

	moveToPos: (x, y) ->
		u = @unit
		xp = x - u.x
		yp = y - u.y
		ur = @unit.data.moveRadius
		if xp * xp + yp * yp >= ur * ur
			v = @vPos
			v.x = x
			v.y = y
			u.setAnim 'walk'
			@setVecMove xp, yp
		this

	updatePostion: (delta) ->
		# update movement
		u = @unit
		v = @vMove
		x = v.x
		y = v.y
		if x != 0 || y !=0
			speed = delta * u.getProp 'speed'
			u.x += x * speed
			u.y += y * speed
		this

	stopWhenRadius: (radius) ->
		# check when end
		u = @unit
		v = @vPos
		xp = v.x - u.x
		yp = v.y - u.y
		if xp * xp + yp * yp >= radius * radius
			u.model.animation.scale = u.data.speedScale * u.getProp 'speed'
		else
			u.stop()
		this

	update: (time, delta) ->
		@updatePostion delta
		@stopWhenRadius @unit.data.moveRadius
		this

UnitState =
	UnitMove: UnitMove

export { UnitState }
