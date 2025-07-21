extends Label


func _on_gun_mag_update(mag_size: int, current: int) -> void:
	self.text=str(current)+"/"+str(mag_size)
