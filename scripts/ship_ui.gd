extends Control

@export var crosshair_color_neutral := Color.from_rgba8(255, 255, 255)
@export var crosshair_color_targeting := Color.from_rgba8(255, 0, 0)

@onready var mag_bar: ProgressBar = $MagContainer/MagBar
@onready var label: Label = $MagContainer/MagBar/Label
@onready var health_bar: ProgressBar = $HealthContainer/HealthBar
@onready var crosshair: Sprite2D = $Crosshair
	

func _ready() -> void:
	Manager.ship_spawned.connect(check)
	Manager.damage.connect(func(dmg, d1, d2):
		if multiplayer.get_unique_id()==1:
			print("%s did %s damage to %s" % [d1, dmg, d2])	
	)	
	
	for id in Manager.ships:
		check(Manager.ships[id])


func check(ship: Ship) -> void:
	if ship.id == multiplayer.get_unique_id():
		ship.health_update.connect(_on_health_update)
		ship.gun.mag_update.connect(_on_mag_update)
		ship.crosshair_position.connect(_on_crosshair_position)
		ship.crosshar_state.connect(_on_crosshar_state)


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
