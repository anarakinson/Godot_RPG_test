extends Control


var hearts = 4 setget set_hearts
var max_hearts = 4 setget set_max_hearts

onready var label = $Label
onready var hearts_full = $HeartsFull
onready var hearts_empty = $HeartsEmpty

func set_hearts(value):
	hearts = clamp(value, 0, max_hearts) # hearts can not be greater than max_hearts and lesser than zero
	if label != null:
		label.text = "HP = " + str(hearts)
	if hearts_full != null:
		hearts_full.rect_size.x = hearts * 15
	
func set_max_hearts(value):
	max_hearts = max(value, 1) # max_hearts can not be lesser than 1
	self.hearts = min(hearts, max_hearts)
	if hearts_empty != null:
		hearts_empty.rect_size.x = max_hearts * 15

func _ready():
	self.max_hearts = PlayerStats.max_health
	self.hearts = PlayerStats.health
	PlayerStats.connect("health_changed", self, "set_hearts")
	PlayerStats.connect("max_health_changed", self, "set_max_hearts")
	
