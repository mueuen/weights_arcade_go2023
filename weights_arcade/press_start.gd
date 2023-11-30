extends Sprite2D

const BLINK_TIME = 0.8

var active = true
var blinkTimer = BLINK_TIME

func set_active(isActive):
	active = isActive
	if active:
		blinkTimer = BLINK_TIME
		show()
	else:
		hide()


func _process(delta):
	if !active:
		return

	blinkTimer = move_toward(blinkTimer, 0.0, delta)
	if blinkTimer == 0.0:
		visible = !visible
		blinkTimer = BLINK_TIME
