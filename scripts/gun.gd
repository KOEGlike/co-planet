class_name Gun

extends Node3D

const BULLET_SCENE:=preload("res://scenes/bullet.tscn")
@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner

signal mag_update(mag_size:int, current:int)

@export var bullet_speed:=25
@export var bullet_damage:=5

@export var mag_size:=20
@export var reload_time:=0.5

@onready var timer: Timer = $Timer

var id:int

var mag:=mag_size:
	set(val):
		if val<0:
			val=0
		mag=val
		mag_update.emit(mag_size,mag)
		
		

func _ready() -> void:
	timer.wait_time=reload_time
	mag=mag_size
	
	multiplayer_spawner.spawn_function=func(data):
		print("kaka")
		var bullet:Bullet=BULLET_SCENE.instantiate()
		bullet.set_name("bullet" + str(get_child_count()+1))
		bullet.position.z-=0.1
		
		bullet.target=data["target"]
		bullet.speed=data["bullet_speed"]
		bullet.damage=data["bullet_damage"]
		print("dddd " + str(bullet))
		return bullet

func shoot(target: Vector3):
	if mag<=0:
		return
	
	mag-=1
	
	var dict:={}
	dict["target"]=target
	dict["bullet_speed"]=bullet_speed
	dict["bullet_damage"]=bullet_damage
	
	var bullet=multiplayer_spawner.spawn(dict)
	print(bullet)
	bullet.top_level=true
	print("shot")


func _on_timer_timeout() -> void:
	if mag<mag_size:
		mag+=1
