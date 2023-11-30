extends Node2D

signal weight_selected(selectedWeight)
signal unplace_weight

const MARGIN = 64.0

var width = 0.0
var height = 0.0
var basePosition = 0.0

var movingLeft = false
var selecting = false
var numWeights = 0
var weightPositions = []
var weightSourcePool = []
var weightSelectPool = []
var weightSelectIndex = 0

func dismiss_weights():
	weightPositions = []
	weightSourcePool = []
	weightSelectPool = []
	weightSelectIndex = 0


func set_as_idle():
	$cursor.hide()
	selecting = false


func set_as_selecting():
	set_cursor_position()
	$cursor.show()
	selecting = true


func select_next_weight():
	weightSelectIndex = (weightSelectIndex + 1) % weightSelectPool.size()


func select_previous_weight():
	weightSelectIndex = (weightSelectIndex + weightSelectPool.size() - 1) % weightSelectPool.size()


func set_cursor_position():
	while weightSelectPool[weightSelectIndex] == null:
		if movingLeft:
			select_previous_weight()
		else:
			select_next_weight()
	movingLeft = false
	var hoveredWeight = weightSelectPool[weightSelectIndex]

	$cursor.position.x = hoveredWeight.position.x
	$cursor.position.y = hoveredWeight.position.y - hoveredWeight.get_size().y - 8


func set_num_weights(newNumWeights):
	weightPositions.clear()
	numWeights = newNumWeights
	for n in range(numWeights):
		var newPosition = basePosition + (width - MARGIN * 2.0) * float(n) / float(numWeights - 1)
		weightPositions.push_back(newPosition)


func add_weight(newWeight):
	weightSelectPool.push_back(newWeight)
	weightSourcePool.push_back(newWeight)
	newWeight.position.x = weightPositions[weightSourcePool.size() - 1]
	newWeight.position.y = -height / 2.0
	add_child(newWeight)


func readd_weight(weight):
	for i in range(weightSourcePool.size()):
		var w = weightSourcePool[i]
		if weight == w:
			weight.position.y = -height / 2.0
			weight.position.x = weightPositions[i]
			weightSelectPool[i] = weight
			weightSelectIndex = i
			break
	add_child(weight)


func _ready():
	height = $color_rect.size.y
	width = $color_rect.size.x
	basePosition = (width - MARGIN * 2.0) / -2.0


func _input(event):
	if selecting == false:
		return

	if event.is_action_pressed("weights_move_right"):
		$tick_sndplayer.play()
		select_next_weight()
		set_cursor_position()
	elif event.is_action_pressed("weights_move_left"):
		$tick_sndplayer.play()
		select_previous_weight()
		movingLeft = true
		set_cursor_position()

	if event.is_action_pressed("weights_select"):
		weight_selected.emit(weightSelectPool[weightSelectIndex])
		weightSelectPool[weightSelectIndex] = null
		set_as_idle()
	elif event.is_action_pressed("weights_deselect"):
		unplace_weight.emit()
