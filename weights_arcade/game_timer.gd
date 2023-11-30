extends Label

signal out_of_time # LMAO

var time = 0.0
var counting = false

func set_time(newTime):
	time = newTime


func start_counting():
	counting = true


func stop_counting():
	counting = false


func _process(delta):
	var seconds: int
	var centiseconds: int

	seconds = int(time)
	centiseconds = int(time * 100.0) % 100
	text = "%d.%02d" % [seconds, centiseconds]

	if counting == false:
		return

	time = clamp(time - delta, 0.0, INF)
	if time == 0.0:
		out_of_time.emit()
		counting = false
