class_name Ship

extends RigidBody3D

@onready var camera: Camera3D = $Camera3D
@onready var gun: Gun = $Gun
@onready var ships: Node = %Ships
@onready var crosshair: Sprite2D = $Control/Crosshair
@onready var control: Control = $Control

signal health_update(max:int, current:int)

@export var max_health:=100

var health:=max_health:
	set(val):
		if val<0:
			val=0
		health_update.emit(max_health, val)
		health=val

@export_category("camera")
@export var camera_offset :=Vector3(-3, 1, 2)
@export var camera_fov:float=90.0
@export var camera_fov_speed:float =1

@export_category("speeds")
@export var rotation_speed:=3
@export var pitch_speed:=5
@export var speed:=10
@export var pitch :=30

@export_category("target")
@export var target:Node3D=null

var dir:float=0

var ships_on_screen:Array[Ship]=[]

func on_new_ship(node:Node) ->void:
	if node is Ship and node != self:
		var ship:Ship=node
		var visiblity:VisibleOnScreenNotifier3D=ship.get_node("VisibleOnScreen")
		
		var on_ship_entered_screen:=func():
			ships_on_screen.append(ship)
			print(ship.name + " entered")
			print(ships_on_screen)
		visiblity.screen_entered.connect(on_ship_entered_screen)
		
		var on_ship_exited_screen:=func():
			ships_on_screen.erase(ship)
			print(ship.name + "exited")
			print(ships_on_screen)
		visiblity.screen_exited.connect(on_ship_exited_screen)
		
func on_ship_exit(node:Node) ->void:
	if node is Ship and node != self:
		ships_on_screen.erase(node)

func _ready() -> void:
	ships.child_entered_tree.connect(on_new_ship)
	ships.child_exiting_tree.connect(on_ship_exit)
	for child in ships.get_children():
		on_new_ship(child)
	
func _physics_process(delta: float) -> void:
	if !camera.current:
		return
	
	global_rotation.z=0
	
	var y_axis:=-Input.get_axis("left","right")
	rotate_y(y_axis * rotation_speed * delta)
	
	var z_axis:=Input.get_axis("up", "down")    
	dir=-z_axis
	global_rotation.x=lerp(global_rotation.x, dir * deg_to_rad(pitch), 0.1)
	
	if Input.is_action_pressed("go"): 
		self.global_position+= -transform.basis.z * speed * delta
		camera.fov=lerp(camera.fov, camera_fov+ self.linear_velocity.length() * camera_fov_speed, 0.1)
	else :
		camera.fov=lerp(camera.fov, camera_fov, 0.1)
		
	
	
	var camera_position := self.global_position + (camera_offset + -dir * Vector3(0,0.5,0)).rotated(Vector3(0,1,0), self.global_rotation.y+PI/2)
	camera.global_position = lerp(camera.global_position, camera_position, delta*rotation_speed)
	
	var current_rotation := Quaternion(camera.global_transform.basis)
	var next_rotation := current_rotation.slerp(Quaternion(self.global_transform.basis), delta*pitch_speed)
	camera.basis = Basis(next_rotation)

func _process(delta: float) -> void:
	control.visible=camera.current
	if !camera.current:
		return
	
	if ships_on_screen.is_empty():
		target=null
	
	if Input.is_action_just_pressed("shoot"):
		var direc:=gun.global_position
		if target!=null:
			direc = target.global_position
		gun.shoot(direc)
	
	if target!=null:
		var pos:=camera.unproject_position(target.global_position)
		crosshair.position=lerp(crosshair.position, pos, 0.3)
	else:
		crosshair.position=get_viewport().size/2
	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion: 
		var closest:Node3D
		var dist:float=INF
		print("mouse: " + str(event.position))
		for ship in ships_on_screen:
			var cur_dist:float=event.position.distance_squared_to(camera.unproject_position(ship.global_position))
			print("cur dist" + str(cur_dist))
			if cur_dist < dist:
				dist=cur_dist
				closest=ship
		target=closest
		
		


func _on_body_entered(body: Node) -> void:
	if body is Bullet:
		health-=body.damage
		print("got " + str(body.damage) + "damage; health: " + str(health))
		


func _on_health_update(_max: int, current: int) -> void:
	if current == 0:
		queue_free() # Replace with function body.
