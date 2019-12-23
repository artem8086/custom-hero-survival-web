class Selection
	pickFromScreen: (x, y) ->
		v = @pickCursor x, y
		v = @getGroundPoint v
		v.y = v.z
		v2 = @checkColission v.x, v.y
		if v2 then v2 else v

export { Selection }