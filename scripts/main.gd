extends Node3D

func _ready() -> void:
	Manager.player_loaded_rpc.rpc(multiplayer.get_unique_id())
