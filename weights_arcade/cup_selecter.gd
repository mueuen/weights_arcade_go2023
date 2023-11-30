extends Node2D

signal cup_selected(currentWeight, cup)
signal weight_deselected(currentWeight)

@export var leftCup: Node2D
@export var rightCup: Node2D

var cupChoices = []
var choiceIndex = 0
var selecting = false
var selectedWeight = null

func set_cup_index(newCupIndex):
	choiceIndex = newCupIndex % 2


func get_cup_index():
	return choiceIndex


func set_as_idle():
	selectedWeight = null
	$cursor.hide()
	selecting = false


func set_as_selecting():
	set_cursor_position()
	$cursor.show()
	selecting = true


func set_selected_weight(newSelectedWeight):
	selectedWeight = newSelectedWeight
	add_child(newSelectedWeight)


func set_cursor_position():
	var selectedCup = cupChoices[choiceIndex]

	$cursor.position.x = selectedCup.position.x + selectedCup.get_next_weight_position()
	$cursor.position.y = selectedCup.position.y + 256.0 - selectedCup.get_stack_height() - 32.0
	if selectedWeight != null:
		selectedWeight.position = $cursor.position
		selectedWeight.position.y = $cursor.position.y + selectedWeight.get_size().y / 2 - 12


func _input(event):
	if !selecting:
		return

	if event.is_action_pressed("weights_move_right"):
		var prevIndex = choiceIndex
		choiceIndex = clamp(choiceIndex + 1, 0 , 1)
		if choiceIndex != prevIndex:
			$tick_sndplayer.play()
		set_cursor_position()
	elif event.is_action_pressed("weights_move_left"):
		var prevIndex = choiceIndex
		choiceIndex = clamp(choiceIndex - 1, 0 , 1)
		if choiceIndex != prevIndex:
			$tick_sndplayer.play()
		set_cursor_position()

	if event.is_action_pressed("weights_select"):
		cup_selected.emit(selectedWeight, choiceIndex)
	elif event.is_action_pressed("weights_deselect"):
		weight_deselected.emit(selectedWeight)


func _ready():
	assert(leftCup != null, "Come on bro don't forget the left cup")
	assert(rightCup != null, "Come on bro don't forget the right cup")
	cupChoices.push_back(leftCup)
	cupChoices.push_back(rightCup)


func _process(_delta):
	if selecting:
		set_cursor_position()
