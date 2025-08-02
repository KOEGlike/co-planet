class_name MultiplayerClient

extends WsClient

var rtc_mp := WebRTCMultiplayerPeer.new()

const SIGNALING_SERVER_URL = "localhost:3000"

func _init() -> void:
	disconnected.connect(_disconnected)

	offer_received.connect(_offer_received)
	answer_received.connect(_answer_received)
	candidate_received.connect(_candidate_received)

	lobby_joined.connect(_lobby_joined)
	peer_connected.connect(_peer_connected)
	peer_disconnected.connect(_peer_disconnected)

func start(lobby: String = "", mesh: bool = true, url: String = SIGNALING_SERVER_URL) -> void:
	stop()
	self.mesh = mesh
	self.lobby = lobby
	connect_to_url(url)

func stop() -> void:
	multiplayer.multiplayer_peer = null
	rtc_mp.close()
	close()

func _create_peer(id: int) -> WebRTCPeerConnection:
	var peer: WebRTCPeerConnection = WebRTCPeerConnection.new()
	# Use a public STUN server for moderate NAT traversal.
	# Note that STUN cannot punch through strict NATs (such as most mobile connections),
	# in which case TURN is required. TURN generally does not have public servers available,
	# as it requires much greater resources to host (all traffic goes through
	# the TURN server, instead of only performing the initial connection).
	peer.initialize({
		"iceServers": [
			{"urls": "stun:stun.l.google.com:19302"},
			{"urls": "stun:stun.l.google.com:5349"},
			{"urls": "stun:stun1.l.google.com:3478"},
			{"urls": "stun:stun1.l.google.com:5349"},
			{"urls": "stun:stun2.l.google.com:19302"},
			{"urls": "stun:stun2.l.google.com:5349"},
			{"urls": "stun:stun3.l.google.com:3478"},
			{"urls": "stun:stun3.l.google.com:5349"},
			{"urls": "stun:stun4.l.google.com:19302"},
			{"urls": "stun:stun4.l.google.com:5349"}
		]
	})
	peer.session_description_created.connect(_offer_created.bind(id))
	peer.ice_candidate_created.connect(_new_ice_candidate.bind(id))
	rtc_mp.add_peer(peer, id)
	if id < rtc_mp.get_unique_id():
		peer.create_offer()
	return peer
	
func _new_ice_candidate(mid_name: String, index_name: int, sdp_name: String, id: int) -> void:
	# print("candidate sent, id: ", str(id))
	send_candidate(id, mid_name, index_name, sdp_name)

func _offer_created(type: String, data: String, id: int) -> void:
	if not rtc_mp.has_peer(id):
		# print("peer doesnt exist: ",str(id))
		return
	# print("created: ", type, " uni: " + str(multiplayer.get_unique_id()))
	rtc_mp.get_peer(id).connection.set_local_description(type, data)
	if type == "offer": send_offer(id, data)
	else: send_answer(id, data)

func _lobby_joined(id: int, _lobby: String, use_mesh: bool) -> void:
	# print("Connected %d, mesh: %s" % [id, use_mesh])
	if use_mesh:
		rtc_mp.create_mesh(id)
	elif id == 1:
		rtc_mp.create_server()
	else:
		rtc_mp.create_client(id)
	
	multiplayer.multiplayer_peer = rtc_mp
	
	# print("unique id" + str(multiplayer.get_unique_id()), " is server:", str(multiplayer.is_server()))
	
	lobby = _lobby


func _disconnected() -> void:
	print("Disconnected: %d: %s" % [code, reason])


func _peer_connected(id: int) -> void:
	print("ws peer connected: %d uni:" % id + str(multiplayer.get_unique_id()))
	_create_peer(id)


func _peer_disconnected(id: int) -> void:
	if rtc_mp.has_peer(id):
		rtc_mp.remove_peer(id)


func _offer_received(id: int, offer: String) -> void:
	# print("Got offer from: %d" % id)
	if rtc_mp.has_peer(id):
		rtc_mp.get_peer(id).connection.set_remote_description("offer", offer)
	else:
		print("got offer, peer ", str(id), " doesnt exist")


func _answer_received(id: int, answer: String) -> void:
	# print("Got answer: %d" % id)
	if rtc_mp.has_peer(id):
		rtc_mp.get_peer(id).connection.set_remote_description("answer", answer)


func _candidate_received(id: int, mid: String, index: int, sdp: String) -> void:
	# print("candidate received, id: ",str(id))
	if rtc_mp.has_peer(id):
		rtc_mp.get_peer(id).connection.add_ice_candidate(mid, index, sdp)
