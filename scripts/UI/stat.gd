class_name Stat
extends HBoxContainer

var kills: int:
	set(val):
		kills = val
		kill_label.text = str(kills)

var damage: int:
	set(val):
		damage = val
		damage_label.text = str(damage)

var deaths: int:
	set(val):
		deaths = val
		deaths_label.text = str(deaths)

var player_name: String:
	set(val):
		player_name = val
		player_name_label.text = player_name + ":"

var id: int

@onready var kill_label: Label = $Kill
@onready var damage_label: Label = $Damage
@onready var deaths_label: Label = $Deaths
@onready var player_name_label: Label = $PlayerName

func _ready() -> void:
	kills=0
	deaths=0
	damage=0
