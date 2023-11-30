extends Node2D

const SND_PLACE1 = preload("res://weights_arcade/snd/place1.wav")
const SND_PLACE2 = preload("res://weights_arcade/snd/place2.wav")
const SND_LARGE = preload("res://weights_arcade/snd/heavy.wav") # she's so
const PLACE_SOUNDS = [SND_PLACE1, SND_PLACE2]

const SCENE_WEIGHT_SMALL = preload("res://weights_arcade/weight_small.tscn")
const SCENE_WEIGHT_WC2 = preload("res://weights_arcade/weight_wc2_small.tscn")
const SCENE_WEIGHT_MED = preload("res://weights_arcade/weight_medium.tscn")
const SCENE_WEIGHT_WC3 = preload("res://weights_arcade/weight_wc3_medium.tscn")
const SCENE_WEIGHT_LARGE = preload("res://weights_arcade/weight_large.tscn")


class WeightInPlay:
	var weight
	var cupIndex


enum WeightClass {
	SMALL_1,
	SMALL_2,
	MEDIUM_1,
	MEDIUM_2,
	LARGE,
	DUMMY
}

enum {	
	STATE_NONE,

	STATE_FADE_IN,
	STATE_TITLE,

	STATE_PRE_ROUND_DELAY,
	STATE_WEIGHT_PALETTE_SELECT,
	STATE_CUP_SELECT,

	STATE_SETTLE,

	STATE_GOOD_RESULT,
	STATE_POST_GOOD_RESULT,

	STATE_BAD_RESULT,
	STATE_POST_BAD_RESULT
}

const GAME_PRESETS = {
	"easy 3" :
	{
		"goalWeightRange" : [8, 44],
		"numWeightsRange" : [3, 3],
		"times" : [10.0],
		"initDelay" : 0.25
	},

	"hard 3" :
	{
		"goalWeightRange" : [8, 44],
		"numWeightsRange" : [3, 3],
		"times" : [5.0],
		"initDelay" : 0.25
	},

	# ----

	"easy 4" :
	{
		"goalWeightRange" : [8, 44],
		"numWeightsRange" : [4, 4],
		"times" : [10.0],
		"initDelay" : 0.5
	},


	"hard 4" :
	{
		"goalWeightRange" : [10, 60],
		"numWeightsRange" : [4, 4],
		"times" : [5.0],
		"initDelay" : 0.25
	},

	# ----

	"easy 5" :
	{
		"goalWeightRange" : [8, 44],
		"numWeightsRange" : [5, 5],
		"times" : [10.0],
		"initDelay" : 0.25
	},

	"med 5" :
	{
		"goalWeightRange" : [30, 50],
		"numWeightsRange" : [5, 5],
		"times" : [10.0],
		"initDelay" : 0.5
	},

	"hard 5" :
	{
		"goalWeightRange" : [20, 44],
		"numWeightsRange" : [5, 5],
		"times" : [5.0],
		"initDelay" : 0.5
	},

	# ----

	"easy 6" :
	{
		"goalWeightRange" : [8, 44],
		"numWeightsRange" : [6, 6],
		"times" : [10.0],
		"initDelay" : 0.25
	},

	"med 6" :
	{
		"goalWeightRange" : [8, 44],
		"numWeightsRange" : [6, 6],
		"times" : [10.0],
		"initDelay" : 0.5
	},

	"hard 6" :
	{
		"goalWeightRange" : [35, 70],
		"numWeightsRange" : [6, 6],
		"times" : [10.0],
		"initDelay" : 0.5
	},

	# ----

	"easy 7" :
	{
		"goalWeightRange" : [8, 44],
		"numWeightsRange" : [7, 7],
		"times" : [15.0],
		"initDelay" : 0.25
	},

	"med 7" :
	{
		"goalWeightRange" : [30, 50],
		"numWeightsRange" : [7, 7],
		"times" : [15.0],
		"initDelay" : 0.5
	},

	"hard 7" :
	{
		"goalWeightRange" : [35, 55],
		"numWeightsRange" : [7, 7],
		"times" : [10.0],
		"initDelay" : 0.75
	},

	# ----
}

var numWeights = 0
var prevGoalWeight = 0
var goalWeight = 0
var weightPool = []
var weightsInPlay = []
var spawnedWeights = []
var gamePresetPool = []

var keepProcessing = true
var queuedState = STATE_NONE
var currState = STATE_FADE_IN

var startPressed = false
var cupIndex = -1
var weightSelected = false
var weightDeselected = false
var selectedWeight = null
var weightUnplaced = false
var outOfTime = false

var lives = 3
var level = 1
var gameTime = 10.0
var delayTimer = 0.0
var hiScore = 314
var fadeInPhase = 0.0

func determine_game_settings():
	var gamePreset
	var goalWeightRange
	var numWeightRange
	var times

	match level:
		1:
			gamePresetPool = [	GAME_PRESETS["easy 3"]]

		5:
			gamePresetPool = [	GAME_PRESETS["easy 4"]]
		6:
			gamePresetPool = [	GAME_PRESETS["easy 3"],
								GAME_PRESETS["easy 4"]]
		10:
			gamePresetPool = [	GAME_PRESETS["easy 5"]]
		11:
			gamePresetPool = [	GAME_PRESETS["easy 4"],
								GAME_PRESETS["easy 5"]]

		20:
			gamePresetPool = [	GAME_PRESETS["easy 6"]]
		22:
			gamePresetPool = [	GAME_PRESETS["easy 4"],
								GAME_PRESETS["easy 5"],
								GAME_PRESETS["easy 6"]]

		30:
			gamePresetPool = [	GAME_PRESETS["easy 7"]]
		34:
			gamePresetPool = [	GAME_PRESETS["easy 4"],
								GAME_PRESETS["easy 7"],
								GAME_PRESETS["easy 5"],
								GAME_PRESETS["easy 6"]]

		40:
			gamePresetPool = [	GAME_PRESETS["hard 3"]]

		45:
			gamePresetPool = [	GAME_PRESETS["hard 3"],
								GAME_PRESETS["easy 4"],
								GAME_PRESETS["easy 5"]]
		50:
			gamePresetPool = [	GAME_PRESETS["hard 4"]]
		55:
			gamePresetPool = [	GAME_PRESETS["hard 4"],
								GAME_PRESETS["hard 3"],
								GAME_PRESETS["easy 5"],
								GAME_PRESETS["easy 6"]]

		60:
			gamePresetPool = [	GAME_PRESETS["med 5"]]
		65:
			gamePresetPool = [	GAME_PRESETS["med 5"],
								GAME_PRESETS["hard 3"],
								GAME_PRESETS["hard 4"],
								GAME_PRESETS["easy 4"]]

		70:
			gamePresetPool = [	GAME_PRESETS["med 6"]]
		75:
			gamePresetPool = [	GAME_PRESETS["med 6"],
								GAME_PRESETS["hard 3"],
								GAME_PRESETS["hard 4"],
								GAME_PRESETS["easy 4"]]
		80:
			gamePresetPool = [	GAME_PRESETS["med 6"],
								GAME_PRESETS["med 5"],
								GAME_PRESETS["hard 3"],
								GAME_PRESETS["hard 4"],
								GAME_PRESETS["easy 4"]]

		80:
			gamePresetPool = [	GAME_PRESETS["hard 5"]]
		85:
			gamePresetPool = [	GAME_PRESETS["hard 5"],
								GAME_PRESETS["hard 3"]]
		90:
			gamePresetPool = [	GAME_PRESETS["easy 3"]]

		100:
			gamePresetPool = [	GAME_PRESETS["med 7"]]
		110:
			gamePresetPool = [	GAME_PRESETS["med 7"],
								GAME_PRESETS["hard 3"],
								GAME_PRESETS["hard 4"]]

		115:
			gamePresetPool = [	GAME_PRESETS["easy 4"],
								GAME_PRESETS["easy 3"]]
		120:
			gamePresetPool = [
								GAME_PRESETS["hard 3"],
								GAME_PRESETS["hard 4"],
								GAME_PRESETS["med 5"],
								GAME_PRESETS["med 6"],
								GAME_PRESETS["med 7"]
			]

		140:
			gamePresetPool = [
								GAME_PRESETS["hard 5"]
			]
		145:
			gamePresetPool = [
								GAME_PRESETS["hard 3"],
								GAME_PRESETS["hard 4"],
								GAME_PRESETS["hard 5"]
			]
		155:
			gamePresetPool = [
								GAME_PRESETS["med 6"],
								GAME_PRESETS["hard 3"],
								GAME_PRESETS["hard 4"],
								GAME_PRESETS["hard 5"]
			]
		160:
			gamePresetPool = [
								GAME_PRESETS["hard 6"]
			]
		170:
			gamePresetPool = [
								GAME_PRESETS["hard 6"],
								GAME_PRESETS["hard 3"],
								GAME_PRESETS["hard 4"],
								GAME_PRESETS["hard 5"],
			]
		190:
			gamePresetPool = [
								GAME_PRESETS["easy 3"]
			]
		200:
			gamePresetPool = [
								GAME_PRESETS["hard 7"]
			]
		230:
			gamePresetPool = [
								GAME_PRESETS["hard 7"],
								GAME_PRESETS["hard 3"],
								GAME_PRESETS["hard 4"]
			]
		# No way to get any harder from here
		240:
			gamePresetPool = [
								GAME_PRESETS["hard 7"],
								GAME_PRESETS["hard 5"],
								GAME_PRESETS["hard 6"],
			]


	gamePreset = gamePresetPool.pick_random()

	goalWeightRange = gamePreset["goalWeightRange"]
	numWeightRange = gamePreset["numWeightsRange"]
	times = gamePreset["times"]

	var newGoalWeight = randi_range(goalWeightRange[0], goalWeightRange[1]) & ~1
	while newGoalWeight == prevGoalWeight:
		newGoalWeight = randi_range(goalWeightRange[0], goalWeightRange[1]) & ~1
	prevGoalWeight = goalWeight
	goalWeight = newGoalWeight

	numWeights = randi_range(numWeightRange[0], numWeightRange[1])
	gameTime = times.pick_random()
	delayTimer = gamePreset["initDelay"]


func generate_weight_pool():
	var weightPool1GoalSize = numWeights / 2
	var weightPool2GoalSize = numWeights - weightPool1GoalSize
	var weightPool1 = []
	var weightPool2 = []
	for i in range(goalWeight / 2):
		weightPool1.push_back(1)
		weightPool2.push_back(1)
	while weightPool1.size() > weightPool1GoalSize:
		var a = randi_range(0, weightPool1.size() - 1)
		var b = randi_range(0, weightPool1.size() - 1)
		while b == a:
			b = randi_range(0, weightPool1.size() - 1)
		var newWeight = weightPool1[a] + weightPool1[b]
		weightPool1[a] = newWeight
		weightPool1.remove_at(b)
	while weightPool2.size() > weightPool2GoalSize:
		var a = randi_range(0, weightPool2.size() - 1)
		var b = randi_range(0, weightPool2.size() - 1)
		while b == a:
			b = randi_range(0, weightPool2.size() - 1)
		var newWeight = weightPool2[a] + weightPool2[b]
		weightPool2[a] = newWeight
		weightPool2.remove_at(b)
	weightPool.append_array(weightPool1)
	weightPool.append_array(weightPool2)
	weightPool.shuffle()


func setup_weight_palette():
	$ui/weight_palette.set_num_weights(numWeights)
	for i in range(numWeights):
		var weightValue = weightPool[i]
		var weightRatio = float(weightValue) / float(goalWeight)
		var weightScene = null
		var weightClass = WeightClass.DUMMY

		if weightRatio < 0.1:
			weightScene = SCENE_WEIGHT_SMALL
			weightClass = WeightClass.SMALL_1
		elif weightRatio < 0.2:
			weightScene = SCENE_WEIGHT_WC2
			weightClass = WeightClass.SMALL_2
		elif weightRatio < 0.3:
			weightScene = SCENE_WEIGHT_MED
			weightClass = WeightClass.MEDIUM_1
		elif weightRatio < 0.4:
			weightScene = SCENE_WEIGHT_WC3
			weightClass = WeightClass.MEDIUM_2
		else:
			weightScene = SCENE_WEIGHT_LARGE
			weightClass = WeightClass.LARGE

		var newWeight = weightScene.instantiate()
		spawnedWeights.push_back(newWeight)
		newWeight.set_weight(weightValue)
		newWeight.set_weight_class(weightClass)
		$ui/weight_palette.add_weight(newWeight)


func dismiss_weights():
	for w in spawnedWeights:
		w.queue_free()
	spawnedWeights.clear()
	weightPool.clear()
	weightsInPlay.clear()


func _ready():
	$bg.change_palette(1, 0.0)


func do_weight_place_sound():
	var soundPlayer = null
	match cupIndex:
		0:
			soundPlayer = $left_place_sndplayer
		1:
			soundPlayer = $right_place_sndplayer

	var weightClass = selectedWeight.get_weight_class()
	var sound = null
	match weightClass:
		WeightClass.LARGE:
			sound = SND_LARGE
		_:
			sound = PLACE_SOUNDS.pick_random()

	var pitchScale = 1.0
	match weightClass:
		WeightClass.SMALL_1:
			pitchScale = 1.5
		WeightClass.SMALL_2:
			pitchScale = 1.22
		WeightClass.MEDIUM_1:
			pitchScale = 1.0
		WeightClass.MEDIUM_2:
			pitchScale = 0.88
		WeightClass.LARGE:
			pitchScale = 0.78

	soundPlayer.stop()
	soundPlayer.pitch_scale = pitchScale
	soundPlayer.stream = sound
	soundPlayer.play()


func _process(delta):
	$bg.set_scroll($scroll_field.get_scroll())

	if queuedState != STATE_NONE:
		currState = queuedState
		queuedState = STATE_NONE

	keepProcessing = true
	while keepProcessing:
		keepProcessing = false

		match currState:
			STATE_FADE_IN:
				fadeInPhase = move_toward(fadeInPhase, 1.0, delta)
				$fade_rect.modulate.a = 1.0 - fadeInPhase
				if fadeInPhase == 1.0:
					startPressed = false
					currState = STATE_TITLE

			STATE_TITLE:
				if startPressed:
					$ui.turn_off_press_start()
					$bgm_player.play_bgm()
					determine_game_settings()
					$ui/goal_weight.text = "Goal: %d lb" % (goalWeight / 2)
					$ui/big_goal_weight.set_weight(goalWeight / 2)
					dismiss_weights()
					generate_weight_pool()
					setup_weight_palette()
					$scroll_field/scale.set_goal_weight(goalWeight)
					$scroll_field/scale/cup_selecter.set_cup_index(0)

					weightSelected = false
					weightUnplaced = false
					selectedWeight = null

					$ui/game_timer.set_time(gameTime)

					currState = STATE_PRE_ROUND_DELAY

			STATE_PRE_ROUND_DELAY:
				delayTimer = move_toward(delayTimer, 0.0, delta)
				if delayTimer == 0.0:
					$ui/weight_palette.set_as_selecting()
					$ui/game_timer.start_counting()

					currState = STATE_WEIGHT_PALETTE_SELECT

			STATE_WEIGHT_PALETTE_SELECT:
				if outOfTime:
					$ui/weight_palette.set_as_idle()
					currState = STATE_SETTLE
				elif weightSelected:
					$scroll_field/scale/cup_selecter.set_as_selecting()
					$ui/weight_palette.remove_child(selectedWeight)
					$scroll_field/scale/cup_selecter.set_selected_weight(selectedWeight)

					cupIndex = -1
					weightDeselected = false

					currState = STATE_CUP_SELECT
				elif weightUnplaced && !weightsInPlay.is_empty():
					var unplacedWeightInPlay = weightsInPlay.pop_back()
					var unplacedWeight = unplacedWeightInPlay.weight
					var unplacedCupIndex = unplacedWeightInPlay.cupIndex
					$ui/weight_palette.set_as_idle()
					$scroll_field/scale.remove_weight(unplacedWeight, unplacedCupIndex)
					$scroll_field/scale/cup_selecter.set_cup_index(unplacedCupIndex)
					$scroll_field/scale/cup_selecter.set_as_selecting()
					$scroll_field/scale/cup_selecter.set_selected_weight(unplacedWeight)
	
					selectedWeight = unplacedWeight
					cupIndex = -1
					weightDeselected = false
					currState = STATE_CUP_SELECT

			STATE_CUP_SELECT:
				if outOfTime:
					cupIndex = $scroll_field/scale/cup_selecter.get_cup_index()
					$scroll_field/scale/cup_selecter.set_as_idle()
					$scroll_field/scale/cup_selecter.remove_child(selectedWeight)
					$scroll_field/scale.add_weight(selectedWeight, cupIndex)

					do_weight_place_sound()

					currState = STATE_SETTLE
				elif cupIndex != -1:
					var newWeightInPlay = WeightInPlay.new()
					newWeightInPlay.weight = selectedWeight
					newWeightInPlay.cupIndex = cupIndex
					weightsInPlay.push_back(newWeightInPlay)

					$scroll_field/scale/cup_selecter.set_as_idle()
					$scroll_field/scale/cup_selecter.remove_child(selectedWeight)
					$scroll_field/scale.add_weight(selectedWeight, cupIndex)

					do_weight_place_sound()

					if weightsInPlay.size() == weightPool.size():
						$ui/game_timer.stop_counting()
						currState = STATE_SETTLE
					else:
						$ui/weight_palette.set_as_selecting()
						weightSelected = false
						selectedWeight = null
						weightUnplaced = false

						currState = STATE_WEIGHT_PALETTE_SELECT
				elif weightDeselected:
					$scroll_field/scale/cup_selecter.set_as_idle()
					$scroll_field/scale/cup_selecter.remove_child(selectedWeight)

					$ui/weight_palette.readd_weight(selectedWeight)
					$ui/weight_palette.set_as_selecting()
					weightSelected = false
					selectedWeight = null
					weightUnplaced = false
					currState = STATE_WEIGHT_PALETTE_SELECT

			STATE_SETTLE:
				outOfTime = false
				var settled = $scroll_field/scale.has_settled()
				if settled:
					var tilt = $scroll_field/scale.get_tilt()
					if tilt == 0 && weightsInPlay.size() == weightPool.size():
						currState = STATE_GOOD_RESULT
					else:
						currState = STATE_BAD_RESULT

			STATE_GOOD_RESULT:
				$ui/good.show()
				$good_sndplayer.play()
				delayTimer = 1.0
				currState = STATE_POST_GOOD_RESULT

			STATE_POST_GOOD_RESULT:
				delayTimer = move_toward(delayTimer, 0.0, delta)
				if delayTimer == 0.0:
					$ui/good.hide()
					$scroll_field/scale.dismiss_weights()
					$ui/weight_palette.dismiss_weights()
					dismiss_weights()

					if level % 5 == 0:
						$bg.change_palette(randi(), 0.5)

					if level % 10 == 0:
						lives = clampi(lives + 1, 0, 5)
						$ui/lives.text = "Lives: %d" % lives

					determine_game_settings()
					level += 1
					if level > hiScore:
						hiScore = level
						$ui/hiscore.text = "Hiscore: %d" % level
					$ui/level.text = "Level: %d" % level
					$ui/goal_weight.text = "Goal: %d lb" % (goalWeight / 2)
					$ui/big_goal_weight.set_weight(goalWeight / 2)
					weightPool.clear()
					generate_weight_pool()
					setup_weight_palette()
					$scroll_field/scale/cup_selecter.set_cup_index(0)
					$scroll_field/scale.set_goal_weight(goalWeight)
					weightsInPlay.clear()

					weightSelected = false
					selectedWeight = null
					weightUnplaced = false

					$ui/game_timer.set_time(gameTime)

					currState = STATE_PRE_ROUND_DELAY

			STATE_BAD_RESULT:
				lives -= 1

				if lives == 0:
					$ui/level.text = "Level: 1"
					$ui/lives.text = "Lives: 3"

					$bg.change_palette(1, 0.5)
					$ui/goal_weight.text = ""
					$scroll_field/scale.dismiss_weights()
					$ui/weight_palette.dismiss_weights()
					dismiss_weights()
					$bgm_player.fade_out_bgm()

					$ui.turn_on_press_start()
					$ui/game_timer.set_time(0.0)
					startPressed = false
					level = 1
					lives = 3

					currState = STATE_TITLE
				else:
					$ui/lives.text = "Lives: %d" % lives
					$ui/bad.show()
					$bad_sndplayer.play()
					delayTimer = 1.0
					currState = STATE_POST_BAD_RESULT

			STATE_POST_BAD_RESULT:
				delayTimer = move_toward(delayTimer, 0.0, delta)
				if delayTimer == 0.0:
					$ui/bad.hide()
					$scroll_field/scale.dismiss_weights()
					$ui/weight_palette.dismiss_weights()
					dismiss_weights()

					determine_game_settings()
					$ui/goal_weight.text = "Goal: %d lb" % (goalWeight / 2)
					$ui/big_goal_weight.set_weight(goalWeight / 2)
					generate_weight_pool()
					setup_weight_palette()
					$scroll_field/scale/cup_selecter.set_cup_index(0)
					$scroll_field/scale.set_goal_weight(goalWeight)

					weightSelected = false
					selectedWeight = null
					weightUnplaced = false

					$ui/game_timer.set_time(gameTime)

					currState = STATE_PRE_ROUND_DELAY


func _input(event):
	if event.is_action_pressed("start_game"):
		startPressed = true


func _on_cup_selecter_cup_selected(_currentWeight, newCupIndex):
	cupIndex = newCupIndex


func _on_weight_palette_unplace_weight():
	weightUnplaced = true


func _on_weight_palette_weight_selected(newSelectedWeight):
	weightSelected = true
	selectedWeight = newSelectedWeight


func _on_cup_selecter_weight_deselected(_currentWeight):
	weightDeselected = true


func _on_game_timer_out_of_time():
	outOfTime = true
