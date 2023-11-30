extends CharacterBody2D

signal out_of_time(weight)

const GRAVITY = 1400.0

var baseWeight = 1
var compositeWeight = 1
var weightClass = 0

var launchVelocity = Vector2.ZERO
var launched = false
var baseTime = 0.0
var time = 0.0
var counting = false

func launch(newLaunchVelocity):
	launched = true
	launchVelocity = newLaunchVelocity


func set_time(newTime):
	baseTime = newTime
	time = baseTime


func get_weight_class():
	return weightClass


func set_weight_class(newWeightClass):
	weightClass = newWeightClass


func show_time():
	$time.show()


func hide_time():
	$time.hide()


func get_time():
	return baseTime


func get_time_remaining():
	return time


func toggle_counting():
	counting = !counting


func start_counting():
	counting = true


func stop_counting():
	counting = false


func set_weight(weight):
	$display/label.text = str(weight) + " lb"
	baseWeight = weight
	compositeWeight = baseWeight


func get_size():
	return $color_rect.get_rect().size


func get_weight():
	return compositeWeight


func process_time_display():
	var seconds: int
	var tenthSeconds: int

	seconds = int(time)
	tenthSeconds = int(time * 10.0) % 10
	$time.text = "%d.%d" % [seconds, tenthSeconds]


func process_time(delta):
	if !counting:
		return

	time = clamp(time - delta, 0.0, INF)
	if time == 0.0:
		out_of_time.emit(self)
		counting = false


func process_physics(delta):
	if !launched:
		return

	launchVelocity.y += GRAVITY * delta
	position += launchVelocity * delta


func _process(delta):
	process_time_display()
	process_time(delta)
	process_physics(delta)
