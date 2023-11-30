extends AudioStreamPlayer

const FADE_TIME = 0.2
const FADE_DIST = -80.0 - -14.5

var fadePhase = 0.0
var fading = false
var baseVolume = 0.0

func play_bgm():
	volume_db = baseVolume
	play()


func fade_out_bgm():
	fading = true


func _ready():
	baseVolume = volume_db


func _process(delta):
	if fading:
		fadePhase = move_toward(fadePhase, 1.0, delta / FADE_TIME)
		volume_db = baseVolume + (FADE_DIST) * fadePhase
		if fadePhase == 1.0:
			stop()
			fading = false
