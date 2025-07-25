extends Node

# Autoload named Lobby

# These signals can be connected to by a UI lobby scene or the game scene.
signal player_connected(peer_id:int, player_info:PlayerInfo)
signal player_disconnected(peer_id:int)
signal server_disconnected

signal ship_spawned(ship:Ship)
signal ship_despawned(ship:Ship)
signal all_players_loaded

const DEFAULT_PORT := 7000
const DEFAULT_SERVER_IP := "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS := 20

class PlayerInfo:
	var name:String="defa"

# This will contain player info for every player,
# with the keys being each player's unique IDs.
var players:Dictionary[int, PlayerInfo]= {}

var ships:Dictionary[int,Ship]={}

# This is the local player info. This should be modified locally
# before the connection is made. It will be passed to every other peer.
# For example, the value of "name" can be set to something the player
# entered in a UI scene.


var player_info :=PlayerInfo.new()

var players_ready := 0

var players_loaded :={}

static func _static_init() -> void:
	ObjectSerializer.register_script("PlayerInfo", PlayerInfo)

func _ready():
	multiplayer.allow_object_decoding = true
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func join_game(address := DEFAULT_SERVER_IP, port:=DEFAULT_PORT):
	
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_client(address, port)
	if error:
		return error
	multiplayer.multiplayer_peer = peer


func create_game(port:=DEFAULT_PORT):
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_server(port, MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer

	players[1] = player_info
	player_connected.emit(1, player_info)


func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = null
	players.clear()


# When the server decides to start the game from a UI scene,
# do Lobby.load_game.rpc(filepath)
@rpc("call_local", "reliable")
func load_game_rpc(game_scene_path:String):
	get_tree().change_scene_to_file(game_scene_path)


# Every peer will call this when they have loaded the game scene.
@rpc("any_peer", "call_local", "reliable")
func player_ready_rpc():
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
	print("connected " + str(id))
	_register_player(player_info,id)

func _register_player(new_player_info: PlayerInfo,id:int=0) -> void:
	var json:=DictionarySerializer.serialize_json(new_player_info)
	if id==0:
		_register_player_rpc.rpc(json)
	else:
		_register_player_rpc.rpc_id(id, json)
	
	

@rpc("any_peer", "reliable")
func _register_player_rpc(new_player_info_json):
	var new_player_info:PlayerInfo=DictionarySerializer.deserialize_json(new_player_info_json)
	
	var new_player_id := multiplayer.get_remote_sender_id()
	players[new_player_id]= new_player_info
	player_connected.emit(new_player_id, new_player_info)


func _on_player_disconnected(id):
	players.erase(id)
	player_disconnected.emit(id)


func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)


func _on_connected_fail():
	multiplayer.multiplayer_peer = null


func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	players.clear()
	server_disconnected.emit()
	
