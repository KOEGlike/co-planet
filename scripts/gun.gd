class_name Gun
extends Node3D

@onready var bullet_spawner: MultiplayerSpawner = $BulletSpawner
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D

signal mag_update(mag_size: int, current: int)

const BULLET_SCENE := preload("res://scenes/bullet.tscn")


@export var bullet_speed := 25
@export var bullet_damage := 5

@export var mag_size := 20
@export var reload_time := 0.5

var mag := mag_size:
	set(val):
		if val < 0:
			val = 0
		mag = val
		mag_update.emit(mag_size, mag)

@onready var timer: Timer = $Timer


func _ready() -> void:
	timer.wait_time = reload_time
	mag = mag_size

	bullet_spawner.spawn_function = func(data):
		var bullet: Bullet = BULLET_SCENE.instantiate()
		bullet.set_name("bullet" + str(get_child_count() + 1))
		bullet.position.z -= 0.1

		bullet.target = data["target"]
		bullet.speed = data["bullet_speed"]
		bullet.damage = data["bullet_damage"]
		bullet.id = data["id"]
		
		audio_stream_player_3d.play()
		
		return bullet


func shoot(target: Vector3):
	if mag <= 0:
		return

	mag -= 1

	var dict := {}
	dict["target"] = target
	dict["bullet_speed"] = bullet_speed
	dict["bullet_damage"] = bullet_damage
	dict["id"] = bullet_spawner.get_multiplayer_authority()

	var bullet = bullet_spawner.spawn(dict)
	bullet.top_level = true


func _on_timer_timeout() -> void:
	if mag < mag_size:
		mag += 1


func _on_tree_entered() -> void:
	pass # Replace with function body.
