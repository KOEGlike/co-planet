class_name Map

extends Node

@onready var asteroid_spawner: MultiplayerSpawner = $AsteroidSpawner

const B2_ASTROID := preload("res://scenes/asteroids/asteroid_2b_2.tscn")
const C2_ASTROID := preload("res://scenes/asteroids/asteroid_2c_2.tscn")
const E2_ASTROID := preload("res://scenes/asteroids/asteroid_2e_2.tscn")
const PACK_ASTROID := preload("res://scenes/asteroids/asteroid_pack.tscn")

const MAX_OFFSET := 200
const ASTEROID_DENSITY := 0.0001

func _ready() -> void:
	asteroid_spawner.set_multiplayer_authority(1)

	asteroid_spawner.spawn_function = create_asteroid


	Manager.all_players_loaded.connect(func():
		if multiplayer.is_server():
			generate_map()
	)
	
func generate_map(max_offset=MAX_OFFSET, density=ASTEROID_DENSITY) -> void:
	var nr_of_asteroids = pow((max_offset * 2), 3) * density

	print("nr of roids ", nr_of_asteroids)
	
	for _i in nr_of_asteroids:
		asteroid_spawner.spawn({})
	
func create_asteroid(_data):
	var i = randi_range(1, 4)
	var asteroid: Node3D
	match i:
		1:
			asteroid = B2_ASTROID.instantiate()
		2:
			asteroid = C2_ASTROID.instantiate()
		3:
			asteroid = E2_ASTROID.instantiate()
		4:
			asteroid = PACK_ASTROID.instantiate()
	
 
	var scale := randf_range(1.5, 2.5)
	asteroid.scale = Vector3(scale + randf_range(-0.1, 0.1), scale + randf_range(-0.1, 0.1), scale + randf_range(-0.1, 0.1))
	asteroid.position = Vector3(randf_range(-MAX_OFFSET, MAX_OFFSET), randf_range(-MAX_OFFSET, MAX_OFFSET), randf_range(-MAX_OFFSET, MAX_OFFSET))
	return asteroid
