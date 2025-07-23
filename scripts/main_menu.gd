extends Control

@onready var name_field: TextEdit = $VBoxContainer/Name


func _on_name_text_changed() -> void:
	Manager.player_info.name=name_field.text


func _on_host_pressed() -> void:
	Manager.create_game()


func _on_join_pressed() -> void:
	Manager.join_game()


func _on_ready_pressed() -> void:
	Manager.player_ready_rpc.rpc()
