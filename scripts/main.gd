extends Node3D

const ship_scene := preload("res://scenes/ship.tscn")

func _ready() -> void:
	spawn_ships()
	
func spawn_ships() -> void:
	var i:int=0
	for player in Manager.players:
		var ship_instace:Ship=ship_scene.instantiate()
		ship_instace.id=player
		ship_instace.name="Ship"+str(player)
		Manager.ships[player]=ship_instace
		add_child(ship_instace)
		ship_instace.global_position.z=i * 2
		i+=1
