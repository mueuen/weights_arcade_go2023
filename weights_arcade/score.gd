extends VBoxContainer

var targetScore = 0
var displayedScore = 0
var countUpTimer = 0.0

func get_score():
	return targetScore


func set_score(newScore):
	targetScore = newScore
	displayedScore = targetScore


func _process(delta):
	countUpTimer += delta
	if displayedScore == targetScore:
		countUpTimer = 0.0
	while countUpTimer > 1.0 / 60.0:
		displayedScore = move_toward(displayedScore, targetScore, 1)
		countUpTimer -= 1.0 / 60.0
	$number.text = "%09d" % displayedScore
