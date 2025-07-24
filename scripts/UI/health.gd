extends ProgressBar
	


func _on_ship_health_update(max_health: int, current: int) -> void:
	self.value=float(current)/float(max_health) * 100
