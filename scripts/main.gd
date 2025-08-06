extends Node3D

@onready var bg_audio_stream_player: AudioStreamPlayer = $BGAudioStreamPlayer

const READY_FIGHT = preload("res://assets/audio/ready_fight.mp3")

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer



func _ready() -> void:
	audio_stream_player.stream = READY_FIGHT
	Manager.player_loaded_rpc.rpc(multiplayer.get_unique_id())


func _on_bg_audio_stream_player_finished() -> void:
	bg_audio_stream_player.play()
