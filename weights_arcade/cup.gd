extends StaticBody2D

@export var positionSequence:Array

class StackedWeight:
	var weight
	var stackIndex


var stackedWeights = []
var positionHeights = []
var compositeWeight = 0
var shortestStackIndex = -1

var explodeTimer = 0.0
var exploding = false

func dismiss_weights():
	stackedWeights.clear()
	
	for i in range(positionHeights.size()):
		positionHeights[i] = 0.0

	compositeWeight = 0
	shortestStackIndex = -1


func explode():
	exploding = true


func remove_weight(weight):
	var swIndex = -1
	var stackIndex = -1
	for i in range(stackedWeights.size()):
		var stackedWeight = stackedWeights[i]
		if stackedWeight.weight == weight:
			swIndex = i
			stackIndex = stackedWeight.stackIndex
			break

	compositeWeight -= weight.get_weight()
	positionHeights[stackIndex] -= weight.get_size().y
	shortestStackIndex = -1

	stackedWeights.remove_at(swIndex)
	remove_child(weight)


func add_weight(weight):
	var newStackedWeight = StackedWeight.new()
	var stackIndex = get_shortest_stack_index()
	newStackedWeight.weight = weight
	newStackedWeight.stackIndex = stackIndex
	stackedWeights.push_back(newStackedWeight)

	weight.position = get_node(positionSequence[stackIndex]).position
	weight.position.y -= positionHeights[stackIndex]
	add_child(weight)
	move_child(weight, 7)

	compositeWeight += weight.get_weight()
	positionHeights[stackIndex] += weight.get_size().y
	shortestStackIndex = -1


func get_shortest_stack_index():
	# Hack since this function gets called every frame
	if shortestStackIndex != -1:
		return shortestStackIndex

	var shortestHeight = 0x7ffffff
	for i in range(len(positionHeights)):
		var height = positionHeights[i]
		if height < shortestHeight:
			shortestHeight = height
			shortestStackIndex = i
	# Convenience hack
	return shortestStackIndex


func get_next_weight_position():
	return get_node(positionSequence[get_shortest_stack_index()]).position.x


func get_stack_height():
	return positionHeights[get_shortest_stack_index()]


func get_tallest_stack():
	var tallestHeight = 0
	for h in positionHeights:
		if h > tallestHeight:
			tallestHeight = h
	return tallestHeight


func get_shortest_stack():
	var shortestHeight = 0x7ffffff
	for h in positionHeights:
		if h < shortestHeight:
			shortestHeight = h
	return shortestHeight


func get_platform_position():
	return $platform.position.y


func get_weight():
	return compositeWeight


func process_explode(_delta):
	if !exploding:
		return

#	if weights.is_empty():
#		return

#	explodeTimer = move_toward(explodeTimer, 0.0, delta)
#	if explodeTimer == 0.0:
#		const CHOICES = [deg_to_rad(-30.0),
#						deg_to_rad(-22.0),
#						deg_to_rad(-15.0),
#						deg_to_rad(15.0),
#						deg_to_rad(22.0),
#						deg_to_rad(30.0)]
#		var angle = CHOICES.pick_random()
#		var explodedWeight = weights.pop_back()
#		explodedWeight.launch(Vector2(0.0, -600.0).rotated(angle))
#		explodeTimer = 0.01


func _process(delta):
	process_explode(delta)


func _ready():
	assert(positionSequence.is_empty() == false, "Cups require a position sequence")
	for i in range(positionSequence.size()):
		positionHeights.push_back(0.0)
