class_name WsClient

extends Node

signal lobby_joined(id: int, lobby: String, use_mesh: bool)
signal disconnected()
signal peer_connected(id: int)
signal peer_disconnected(id: int)
signal offer_received(id: int, offer: String)
signal answer_received(id: int, answer: String)
signal candidate_received(id: int, mid: String, index: int, sdp: String)

@export var autojoin := true
@export var lobby := ""  # Will create a new lobby if empty.
@export var mesh := true  # Will use the lobby host as relay otherwise.

var ws := WebSocketPeer.new()
var code := 1000
var reason := "Unknown"
var old_state := WebSocketPeer.STATE_CLOSED

func connect_to_url(url: String) -> void:
	close()
	code = 1000
	reason = "Unknown"
	ws.connect_to_url(url)


func close() -> void:
	ws.close()


func _process(_delta: float) -> void:
	ws.poll()
	var state := ws.get_ready_state()
	if state != old_state and state == WebSocketPeer.STATE_OPEN and autojoin:
		join_lobby(lobby)
	while state == WebSocketPeer.STATE_OPEN and ws.get_available_packet_count():
		if not _parse_msg():
			print("Error parsing message from server.")
	if state != old_state and state == WebSocketPeer.STATE_CLOSED:
		code = ws.get_close_code()
		reason = ws.get_close_reason()
		disconnected.emit()
	old_state = state
	
func _parse_msg() -> bool:
	var json=JSON.new()
	var error=json.parse(ws.get_packet().get_string_from_utf8())
	if error != OK:
		push_error("json parsing error: " + str(error))
		return false
	
	if typeof(json.data) != TYPE_DICTIONARY:
		push_error("json is not dict")
		return false;
		
	var data: Dictionary=json.data
	
	if not data.has("type"):
		push_error("no type field")
		return false
	var type=data["type"]
	
	match type:
		"id":
			if not data.has("id") or not data.has("lobby_id") or not data.has("mesh"):
				push_error("missing field/s while parsin type of id")
				return false
			lobby_joined.emit(data["id"],data["lobby_id"], data["mesh"])
		"peer_connect":
			if not data.has("id"):
				push_error("missing field id while parsin type of peer_connect")
				return false
			peer_connected.emit(data["id"])
		"peer_disconect":
			if not data.has("id"):
				push_error("missing field id while parsin type of peer_disconect")
				return false
			peer_disconnected.emit(data["id"])
		"relay":
			if not data.has("sender_id") or not data.has("dest_id") or not data.has("message"):
				push_error("missing field/s while parsin type of relay")
				return false
				
			if typeof(data["message"]) != TYPE_DICTIONARY:
				push_error("relay message is not dict")
				return false;
				
			var message:Dictionary=data["message"]
			
			if not message.has("type"):
				push_error("no type field in relay message")
				return false
			
			var relay_type=message["type"]
			
			match relay_type:
				"offer":
					if not message.has("offer"):
						push_error("no offer field in relay offer message")
						return false
					offer_received.emit(data["sender_id"], message["offer"])
				"answer":
					if not message.has("answer"):
						push_error("no answer field in relay answer message")
						return false
					answer_received.emit(data["sender_id"], message["answer"])
				"candidate":
					if not message.has("mid") or not message.has("index") or not message.has("sdp"):
						push_error("no field/s found in relay candidate message")
						return false
					candidate_received.emit(data["sender_id"], message["mid"], message["index"], message["sdp"])
				_:
					push_error("offer type has a wrong value")
					return false
			
		"error":
			push_error("received error from server: " + str(data["error"]))
			
		_:
			push_error("type has a wrong value")
			return false
	
	return true
	
func join_lobby(lobby: String) -> Error:
	var dict:={
		"type":"join"	
	}
	
	if not lobby.is_empty():
		dict["lobby_id"]=lobby
	
	return ws.send_text(JSON.stringify(dict))

func send_candidate(dest_id: int, mid: String, index: int, sdp: String) -> Error:
	return _send_relay(dest_id, {
		"type":"candidate",
		"mid":mid,
		"index":index,
		"sdp":sdp
	})


func send_offer(dest_id: int, offer: String) -> Error:
	return _send_relay(dest_id,{
		"type":"offer",
		"offer":offer
	})


func send_answer(dest_id: int, answer: String) -> Error:
	return _send_relay(dest_id,{
		"type":"answer",
		"answer":answer
	})
	
	
func _send_relay(dest_id:int, message:Dictionary) -> Error:
	return ws.send_text(JSON.stringify({
		"type":"relay",
		"dest_id":dest_id,
		"message":message
	}))
