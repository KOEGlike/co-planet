extends Control

@export var crosshair_color_neutral := Color.from_rgba8(255, 255, 255)
@export var crosshair_color_targeting := Color.from_rgba8(255, 0, 0)

var stats_dict: Dictionary[int, Stat] = {}

@onready var mag_bar: ProgressBar = $MagContainer/MagBar
@onready var label: Label = $MagContainer/MagBar/Label
@onready var health_bar: ProgressBar = $HealthContainer/HealthBar
@onready var crosshair: Sprite2D = $Crosshair
@onready var stats: MarginContainer = $Stats
@onready var killed: Label = $Killed

const STAT = preload("res://scenes/stat.tscn")

func _ready() -> void:
	add_initial_stats()
	
	Manager.ship_spawned.connect(check)

	Manager.damage.connect(func(dmg, d1, d2):
			stats_dict[d1].damage=Manager.player_scores[d1].damage
	)
	Manager.kill.connect(func(killer, killed):
		stats_dict[killer].kills=Manager.player_scores[killer].kills
		stats_dict[killed].deaths=Manager.player_scores[killed].deaths
	)

	for id in Manager.ships:
		check(Manager.ships[id])


func _process(delta: float) -> void:
	stats.visible = Input.is_action_pressed("score")


func add_initial_stats():
	for id in Manager.player_scores:
		var stat_instance:=STAT.instantiate()
		$Stats/StatsContainer.add_child(stat_instance)
		stat_instance.name=str(id)
		if id!=0:
			stat_instance.player_name=Manager.players[id]["name"]
		else:
			stat_instance.player_name="enveriment"
		stat_instance.id=id
		stats_dict[id]=stat_instance
		

func check(ship: Ship) -> void:
	if ship.id == multiplayer.get_unique_id():
		ship.health_update.connect(_on_health_update)
		ship.gun.mag_update.connect(_on_mag_update)
		ship.crosshair_position.connect(_on_crosshair_position)
		ship.crosshar_state.connect(_on_crosshar_state)
		_on_mag_update(ship.gun.mag_size, ship.gun.mag)


func _on_health_update(max: int, current: int) -> void:
	health_bar.value = float(current) / float(max) * 100


func _on_mag_update(mag_size: int, current: int) -> void:
	label.text = str(current) + "/" + str(mag_size)
	mag_bar.value = float(current) / float(mag_size) * 100


func _on_crosshair_position(pos: Vector2) -> void:
	crosshair.position = lerp(crosshair.position, pos, 0.3)


func _on_crosshar_state(state: CrosshairState.CrosshairState) -> void:
	match state:
		CrosshairState.CrosshairState.TARGETING:
			crosshair.self_modulate = crosshair_color_targeting
		CrosshairState.CrosshairState.NEUTRAL:
			crosshair.self_modulate = crosshair_color_neutral
