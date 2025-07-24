extends ProgressBar


func _on_gun_mag_update(mag_size: int, current: int) -> void:
	self.value=float(current)/float(mag_size) * 100
