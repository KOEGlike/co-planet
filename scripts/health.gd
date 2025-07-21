extends ProgressBar
	


func _on_ship_health_update(max: int, current: int) -> void:
	self.value=float(current)/float(max) * 100
