class_name Gun

extends Node3D

const BULLET_SCENE:=preload("res://scenes/bullet.tscn")

signal mag_update(mag_size:int, current:int)

@export var bullet_speed:=25
@export var bullet_damage:=5

@export var mag_size:=20
@export var reload_time:=0.5

@onready var timer: Timer = $Timer

var mag:=mag_size:
	set(val):
		if val<0:
			val=0
		mag=val
		mag_update.emit(mag_size,mag)
		
		

func _ready() -> void:
	timer.wait_time=reload_time
	mag=mag_size

func shoot(target: Vector3):
	if mag<=0:
		return
	
	mag-=1
	var bullet:=BULLET_SCENE.instantiate()
	bullet.set_name("bullet" + str(get_child_count()+1))
	bullet.target=target
	bullet.speed=bullet_speed
	bullet.position.z-=0.1
	bullet.damage=bullet_damage
	add_child(bullet)
	bullet.top_level=true
	print("shot")


func _on_timer_timeout() -> void:
	if mag<mag_size:
		mag+=1
