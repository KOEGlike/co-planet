extends Control

@onready var name_field: TextEdit = $VBoxContainer/Name
@onready var lobby_field: TextEdit = $VBoxContainer/Lobby
@onready var lobby_id: Label = $VBoxContainer/LobbyID

func _ready() -> void:
	Manager.muliplayer_client.lobby_joined.connect(func(id, lobby, mesh):
		lobby_id.text=lobby
		print("id " + str(id) + " lobby " + lobby)
	)

func _on_name_text_changed() -> void:
	Manager.player_info.name=name_field.text

func _on_join_pressed() -> void:
	Manager.join_game(lobby_field.text)


func _on_ready_pressed() -> void:
	Manager.player_ready_rpc.rpc()


 # Replace with function body.


func _on_copy_pressed() -> void:
	DisplayServer.clipboard_set(lobby_id.text)
