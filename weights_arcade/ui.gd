extends Control

var tiltBarAppeared = false

func turn_on_press_start():
	$press_start.set_active(true)


func turn_off_press_start():
	$press_start.set_active(false)


func tilt_bar_has_appeared():
	return tiltBarAppeared


func show_tilt_bar():
	$tilt_bar.appear()
	tiltBarAppeared = true


func get_score():
	return $score.get_score()


func set_score(newScore):
	$score.set_score(newScore)


func set_tilt_ratio(newTiltRatio):
	$tilt_bar.set_tilt_ratio(newTiltRatio)
