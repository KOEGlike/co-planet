extends Control

@onready var name_field: TextEdit = $vbox/NameSelector/Name

@onready var lobby_field: TextEdit = $vbox/HostJoin/LobbySection/LobbyField
@onready var lobby_id: Label = $vbox/Waiting/LobbySection/LobbyID

@onready var host_button: Button = $vbox/HostJoin/HostSection/HostButton
@onready var mesh_check_box: CheckBox = $vbox/HostJoin/HostSection/MeshCheckBox

@onready var name_selector: HBoxContainer = $vbox/NameSelector
@onready var host_join: VBoxContainer = $vbox/HostJoin
@onready var waiting: VBoxContainer = $vbox/Waiting

enum MainMenuState {
	Name,
	HostJoin,
	Ready,
}

var state:MainMenuState=MainMenuState.Name:
	set(x):
		match state:
			MainMenuState.Name:
				name_selector.hide()
			MainMenuState.HostJoin:
				host_join.hide()
			MainMenuState.Ready:
				waiting.hide()
				
		match x:
			MainMenuState.Name:
				name_selector.visible=true
			MainMenuState.HostJoin:
				host_join.visible=true
			MainMenuState.Ready:
				waiting.visible=true
		
		state=x
	get():
		return state

func _on_ok_pressed() -> void:
	if !name_field.text.is_empty():
		Manager.player_info["name"]=name_field.text
		state=MainMenuState.HostJoin

func _on_join_pressed() -> void:
	Manager.join_game(lobby_field.text)
	state=MainMenuState.Ready

func _on_host_button_pressed() -> void:
	Manager.join_game("", mesh_check_box.button_pressed)
	state=MainMenuState.Ready


func _on_ready_pressed() -> void:
	Manager.player_ready_rpc.rpc()

func _on_copy_pressed() -> void:
	DisplayServer.clipboard_set(lobby_id.text)

func _ready() -> void:
	Manager.muliplayer_client.lobby_joined.connect(func(id, lobby, mesh):
		lobby_id.text=lobby
		print("id " + str(id) + " lobby " + lobby)
	)	
