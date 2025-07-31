extends Node3D

const ship_scene := preload("res://scenes/ship.tscn")

@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner

func _ready() -> void:
	multiplayer_spawner.spawn_function=func(data):
		var id=data["id"]
		var ship_instace:Ship=ship_scene.instantiate()
		ship_instace.id=id
		ship_instace.name="Ship"+str(id)
		Manager.ship_spawned.emit(ship_instace)
		return ship_instace
		
	Manager.player_loaded_rpc.rpc(multiplayer.get_unique_id())
	
	Manager.all_players_loaded.connect(func():
		if multiplayer.is_server():
			for id in Manager.players:
				print("spawning player: ",str(id))
				var data={}
				data["id"]=id
				var ship:Ship=multiplayer_spawner.spawn(data)
				ship.global_position=Vector3(randf_range(-10, 10),randf_range(-10, 10),randf_range(-10, 10))
				Manager.ships[id]=ship	
				ship.tree_exiting.connect(func():
					Manager.ship_despawned.emit(ship)
					Manager.ships.erase(id)	
				)
	)
	


func _on_multiplayer_spawner_despawned(ship: Node) -> void:
	if ship is Ship:
		Manager.ship_despawned.emit(ship)
		Manager.ships.erase(ship.id)


func _on_multiplayer_spawner_spawned(ship: Node) -> void:
	if ship is Ship:
		Manager.ship_spawned.emit(ship)
		Manager.ships[ship.id]=ship
