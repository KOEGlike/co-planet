extends Control

@onready var name_field: TextEdit = $VBoxContainer/Name
@onready var port: TextEdit = $VBoxContainer/TabContainer/Host/HBoxContainer/Port


func _on_name_text_changed() -> void:
	Manager.player_info.name=name_field.text


func _on_host_pressed() -> void:
	if port.text.is_empty():
		Manager.create_game()
	else:
		Manager.create_game(int(port.text))


func _on_join_pressed() -> void:
	Manager.join_game()


func _on_ready_pressed() -> void:
	Manager.player_ready_rpc.rpc()
