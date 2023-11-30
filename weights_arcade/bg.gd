extends Node2D

const PALETTES = \
[
	# Dark purp
	[
		Vector3(50.0 / 255.0, 31.0 / 255.0, 104.0 / 255.0),
		Vector3(19.0 / 255.0, 22.0 / 255.0, 76.0 / 255.0)
	],
	# Bluish
	[
		Vector3(26.0 / 255.0, 38.0 / 255.0, 121.0 / 255.0),
		Vector3(51.0 / 255.0, 72.0 / 255.0, 121.0 / 255.0)
	],
	# Greenish
	[
		Vector3(32.0 / 255.0, 81.0 / 255.0, 85.0 / 255.0),
		Vector3(68.0 / 255.0, 118.0 / 255.0, 109.0 / 255.0)
	],
	# Purp and blurp
	[
		Vector3(83.0 / 255.0, 36.0 / 255.0, 122.0 / 255.0),
		Vector3(36.0 / 255.0, 36.0 / 255.0, 122.0 / 255.0)
	],
	# Murky
	[
		Vector3(32.0 / 255.0, 76.0 / 255.0, 59.0 / 255.0),
		Vector3(20.0 / 255.0, 48.0 / 255.0, 63.0 / 255.0)
	]
]

var currPalette = PALETTES[0]
var nextPalette = PALETTES[0]
var changing = false
var changePhase = 0.0
var changeTime = 1.0

func set_bg_colors(color1, color2):
	$back.material.set_shader_parameter("color1", color1)
	$back.material.set_shader_parameter("color2", color2)


func change_palette(newPalette, time):
	nextPalette = PALETTES[newPalette % PALETTES.size()]
	if time > 0.0:
		changing = true
		changePhase = 0.0
		changeTime = time
	else:
		currPalette = nextPalette
		changing = false
		changePhase = 0.0
		set_bg_colors(currPalette[0], currPalette[1])


func set_scroll(newScroll):
	newScroll = fmod(newScroll * 0.4, 32.0)
	newScroll = newScroll - 32.0
	$back.position.y = newScroll


func _process(delta):
	if changing:
		changePhase = move_toward(changePhase, 1.0, delta / changeTime)

		var currColor1 = currPalette[0]
		var currColor2 = currPalette[1]
		var nextColor1 = nextPalette[0]
		var nextColor2 = nextPalette[1]
		var midColor1 = Vector3.ZERO
		var midColor2 = Vector3.ZERO

		midColor1 = currColor1.lerp(nextColor1, changePhase)
		midColor2 = currColor2.lerp(nextColor2, changePhase)
		set_bg_colors(midColor1, midColor2)

		if changePhase == 1.0:
			currPalette = nextPalette
			changing = false
