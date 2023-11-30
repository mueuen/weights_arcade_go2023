extends Node2D

const FADE_TIME = 0.4

var viewportSize = Vector2.ZERO
var tiltRatio = 0.0
var tiltPixels = 0.0
var appearing = false
var appearPhase = 0.0

func appear():
	appearing = true
	modulate.a = 0.0
	show()


func set_tilt_ratio(newTiltRatio):
	tiltRatio = clamp(newTiltRatio, -1.0, 1.0)


func _ready():
	viewportSize = get_viewport_rect().size


func _process(delta):
	if appearing:
		appearPhase = move_toward(appearPhase, 1.0, delta / FADE_TIME)
		modulate.a = sqrt(appearPhase)
		if appearPhase == 1.0:
			appearing = false

	tiltPixels = (viewportSize.x / 2.0 - 32.0) * tiltRatio
	tiltPixels = clamp(	tiltPixels,
						-viewportSize.x / 2.0 + 32.0,
						viewportSize.x / 2.0 - 32.0)
	queue_redraw()


func _draw():
	draw_rect(Rect2(-viewportSize.x / 2.0 + 32.0, -4.0, viewportSize.x - 64.0, 8.0), Color.BLACK)
	draw_rect(Rect2(tiltPixels, -4.0, -tiltPixels, 8.0), Color.GREEN)
