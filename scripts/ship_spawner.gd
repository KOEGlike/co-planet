extends MultiplayerSpawner

func _enter_tree() -> void:
	self.set_multiplayer_authority(1)
