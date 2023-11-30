extends Node2D

const MAX_TILT = 32.0
const TEETER_TIME = 8.2
const TEETER_DEGREES = 0.4
const SETTLE_TIME = 0.8
const FLOAT_TIME = 6.0
const FLOAT_AMP = 3.0

var leftCupWeights = []
var rightCupWeights = []

var handleRotation = 0.0
var teeterPhase = 0.0
var leftTilt = 0.0
var rightTilt = 0.0
var tiltTarget = 0.0
var tilt = 0.0

var goalWeight = 1.0

var settled = false
var settleTimer = SETTLE_TIME

var basePosition = Vector2.ZERO
var floatPhase = 0.0
var floatOffset = 0.0

func explode():
	leftTilt = 0.0
	rightTilt = 0.0
	$cup_left.explode()
	$cup_right.explode()
	$explode_sndplayer.play()


func dismiss_weights():
	$cup_left.dismiss_weights()
	$cup_right.dismiss_weights()
	leftTilt = 0.0
	rightTilt = 0.0


func has_settled():
	return settled


func set_goal_weight(newGoalWeight):
	goalWeight = newGoalWeight


func get_total_weight():
	return $cup_left.get_weight() + $cup_right.get_weight()


func get_tallest_stack(cupIndex):
	var stackHeight = 0
	match cupIndex:
		0:
			stackHeight = -$cup_left.get_tallest_stack()
			stackHeight += $cup_left.position.y
			stackHeight += $cup_left.get_platform_position()
		1:
			stackHeight = -$cup_right.get_tallest_stack()
			stackHeight += $cup_right.position.y
			stackHeight += $cup_right.get_platform_position()
	return stackHeight


func get_lowest_stack(cupIndex):
	var stackHeight = 0
	match cupIndex:
		0:
			stackHeight = -$cup_left.get_shortest_stack()
			stackHeight += $cup_left.position.y
			stackHeight += $cup_left.get_platform_position()
		1:
			stackHeight = -$cup_right.get_shortest_stack()
			stackHeight += $cup_right.position.y
			stackHeight += $cup_right.get_platform_position()
	return stackHeight


func add_weight(weight,  cupIndex):
	match cupIndex:
		0:
			$cup_left.add_weight(weight)
			leftTilt = -MAX_TILT * $cup_left.get_weight() / goalWeight
		1:
			$cup_right.add_weight(weight)
			rightTilt = MAX_TILT * $cup_right.get_weight() / goalWeight


func remove_weight(weight, cupIndex):
	match cupIndex:
		0:
			$cup_left.remove_weight(weight)
			leftTilt = -MAX_TILT * $cup_left.get_weight() / goalWeight
		1:
			$cup_right.remove_weight(weight)
			rightTilt = MAX_TILT * $cup_right.get_weight() / goalWeight


func get_tilt():
	return int(leftTilt + rightTilt)


func process_floating(delta):
	floatPhase = fmod(floatPhase, 1.0)
	floatOffset = FLOAT_AMP * sin(2.0 * PI * floatPhase)
	floatPhase += delta / FLOAT_TIME


func process_teeter(delta):
	teeterPhase = fmod(teeterPhase, 1.0)
	handleRotation += TEETER_DEGREES * sin(2.0 * PI * teeterPhase)
	teeterPhase += delta / TEETER_TIME


func process_tilt(delta):
	var newTiltTarget

	newTiltTarget = leftTilt + rightTilt

	tiltTarget = newTiltTarget
	tilt += (tiltTarget - tilt) * 4.0 * delta

	handleRotation += tilt


func process_settled(delta):
	if abs(tiltTarget - tilt) < 1.0:
		settleTimer = move_toward(settleTimer, 0.0, delta)
		if settleTimer == 0.0:
			settled = true
	else:
		settleTimer = SETTLE_TIME
		settled = false


func _ready():
	basePosition = position


func _physics_process(delta):
	handleRotation = 0.0

	process_floating(delta)
	process_teeter(delta)
	process_tilt(delta)
	process_settled(delta)

	$handle.rotation_degrees = handleRotation
	position.y = basePosition.y + floatOffset

	$cup_left.position = $handle.position + $handle/left.position.rotated($handle.rotation)
	$cup_right.position = $handle.position + $handle/right.position.rotated($handle.rotation)
