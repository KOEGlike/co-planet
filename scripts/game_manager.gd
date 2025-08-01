extends Node

# Autoload named Lobby
@onready var muliplayer_client: MultiplayerClient = $MuliplayerClient
# These signals can be connected to by a UI lobby scene or the game scene.
signal player_connected(peer_id:int, player_info:Dictionary)
signal player_disconnected(peer_id:int)
signal server_disconnected

signal ship_spawned(ship:Ship)
signal ship_despawned(ship:Ship)
signal all_players_loaded

signal player_ready(id:int)


var players:Dictionary[int, Dictionary]= {}
var ships:Dictionary[int,Ship]={}

var player_info :={
	"name":"defa",
	"ready":false
}

var players_ready := 0
var players_loaded :={}


func _ready():
	multiplayer.allow_object_decoding = true
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	muliplayer_client.disconnected.connect(_on_server_disconnected)
	muliplayer_client.peer_disconnected.connect(_on_player_disconnected)


func join_game(lobby:String, mesh:bool=false):
	muliplayer_client.start(lobby, mesh)

# When the server decides to start the game from a UI scene,
# do Lobby.load_game.rpc(filepath)
@rpc("call_local", "reliable")
func load_game_rpc(game_scene_path:String):
	get_tree().change_scene_to_file(game_scene_path)


# Every peer will call this when they have loaded the game scene.
@rpc("any_peer", "call_local", "reliable")
func player_ready_rpc():
	var caller:=multiplayer.get_remote_sender_id()
	player_ready.emit(caller)
	players[caller]["ready"]=true
	if multiplayer.is_server():
		players_ready += 1
		print("added " + str(players_ready))
		if players_ready == players.size():
			print("load game")
			load_game_rpc.rpc("res://scenes/main.tscn")
			players_ready = 0
	
@rpc("any_peer", "call_local", "reliable")		
func player_loaded_rpc(id:int):
	players_loaded[id]=null
	if players_loaded.size() == players.size():
		all_players_loaded.emit()

# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(id:int):
	if not players.has(multiplayer.get_unique_id()):
		print("not has")
		_on_connected_ok()
	print("rtc connected " + str(id) + " self:" + str(multiplayer.get_unique_id()))
	_register_player_rpc.rpc_id(id, player_info)

@rpc("any_peer", "reliable")
func _register_player_rpc(new_player_info: Dictionary):
	
	var new_player_id := multiplayer.get_remote_sender_id()
	players[new_player_id]= new_player_info
	player_connected.emit(new_player_id, new_player_info)


func _on_player_disconnected(id):
	players.erase(id)
	player_disconnected.emit(id)


func _on_connected_ok():
	print("connected ok, self register: ", multiplayer.get_unique_id())
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)


func _on_connected_fail():
	multiplayer.multiplayer_peer = null


func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	players.clear()
	server_disconnected.emit()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	
