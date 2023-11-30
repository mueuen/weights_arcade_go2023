extends Node2D

enum {IN_GAME, PUPPET}

var viewportSize = Vector2.ZERO

var currMode = IN_GAME
var targetHeight = 240.0
var moveFactor = 5.0

func set_target_height(newTargetHeight):
	targetHeight = newTargetHeight


func set_move_factor(newMoveFactor):
	moveFactor = newMoveFactor


func set_in_game():
	currMode = IN_GAME


func set_as_puppet():
	currMode = PUPPET


func get_scroll():
	return position.y


func _ready():
	viewportSize = get_viewport_rect().size


func process_style_1():
	var leftTallStack = position.y + $scale.get_tallest_stack(0) + $scale.position.y
	var rightTallStack = position.y + $scale.get_tallest_stack(1) + $scale.position.y
	var leftShortStack = position.y + $scale.get_lowest_stack(0) + $scale.position.y
	var rightShortStack = position.y + $scale.get_lowest_stack(1) + $scale.position.y
	# These are switched from usual because the "stacks" here are screen positions
	var tallStack = min(leftTallStack, rightTallStack)
	var shortStack = max(leftShortStack, rightShortStack)

	targetHeight = (tallStack + shortStack) * 0.5 + (tallStack - shortStack) * 0.15
	targetHeight = targetHeight - viewportSize.y * 0.5 - position.y
	targetHeight = -targetHeight


func process_style_2():
	targetHeight = 240.0 - $scale/cup_selecter/cursor.position.y - 200.0


func process_in_game():
	process_style_2()


# Camera programming is hard
func _process(delta):
	match currMode:
		IN_GAME:
			process_in_game()

	targetHeight = clamp(targetHeight, 240.0, INF)
	var scrollVelocity = (targetHeight - position.y) * moveFactor
	position.y += scrollVelocity * delta
