class_name Gun

extends Node3D

const BULLET_SCENE:=preload("res://scenes/bullet.tscn")

@export var bullet_speed=15
@export var bullet_damage=5

func shoot(target: Vector3):
	var bullet:=BULLET_SCENE.instantiate()
	bullet.set_name("bullet" + str(get_child_count()+1))
	bullet.target=target
	bullet.speed=bullet_speed
	bullet.position.z-=0.1
	bullet.damage=bullet_damage
	add_child(bullet)
	bullet.top_level=true
	print("shot")
