extends Node

const ship_scene := preload("res://scenes/ship.tscn")

@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner


func _ready() -> void:
	Manager.all_players_loaded.connect(_on_all_players_loaded)

	Manager.player_disconnected.connect(func(id: int):
			var ship := Manager.ships[id]
			if ship != null:
				ship.queue_free()
	)

	multiplayer_spawner.spawn_function = func(data):
		var id = data["id"]
		var ship_instance: Ship = ship_scene.instantiate()
		ship_instance.id = id
		ship_instance.name = "Ship" + str(id)
		return ship_instance


func _on_multiplayer_spawner_despawned(ship: Node) -> void:
	if ship is Ship:
		Manager.ship_despawned.emit(ship)
		Manager.ships.erase(ship.id)


func _on_multiplayer_spawner_spawned(ship: Node) -> void:
	if ship is Ship:
		Manager.ship_spawned.emit(ship)
		Manager.ships[ship.id] = ship


func _on_all_players_loaded():
	if Manager.multiplayer.get_unique_id() == 1:
		for id in Manager.players:
			if Manager.ships.has(id):
				continue

			print("spawning player: ", str(id))
			var data = {}
			data["id"] = id
			var ship: Ship = multiplayer_spawner.spawn(data)
			
			_on_multiplayer_spawner_spawned(ship)
			ship.tree_exiting.connect(func():
					_on_multiplayer_spawner_despawned(ship)
			)
			
			ship.global_position = Vector3(randf_range(-10, 10), randf_range(-10, 10), randf_range(-10, 10))
			Manager.ships[id] = ship
