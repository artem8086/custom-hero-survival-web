obj =
	base_unit:
		animations:
			stand: 'stand'
			walk: 'run'
			attack: 'attack'

		styles:
			default: 'body'

		shadow:
			model: 'models/shadow'
			node: 'shadow'

		scaleModel: 1
		scaleShadow: 1

		height: 100
		width: 80

		radius: 40

		moveRadius: 20
		speedScale: 0.008

		properties:
			speed: 400

	banny:
		extends: 'base_unit'

		name: 'banny'

		styles:
			default: 'banny'

		animation:
			default: 'anims/banny'

		models:
			default: 'models/banny'



