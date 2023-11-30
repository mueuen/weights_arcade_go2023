extends Label

const HOLD_TIME = 0.5

var fading = false
var holdTimer = 0.0
var fadePhase = 0.0

func set_weight(newWeight):
	text = str(newWeight)
	holdTimer = HOLD_TIME
	fadePhase = 0.0
	modulate.a = 1.0
	fading = true


func _process(delta):
	holdTimer = move_toward(holdTimer, 0.0, delta)
	if holdTimer > 0.0:
		return

	if fading:
		fadePhase = move_toward(fadePhase, 1.0, delta)
		modulate.a = 1.0 - fadePhase
		if fadePhase == 1.0:
			fading = false
