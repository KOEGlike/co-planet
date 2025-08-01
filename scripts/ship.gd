class_name Ship

extends RigidBody3D

@onready var camera: Camera3D = $Camera3D
@onready var gun: Gun = $Gun
@onready var crosshair: Sprite2D = $Control/Crosshair
@onready var control: Control = $Control
@onready var ship_synchronizer: MultiplayerSynchronizer = $ShipSynchronizer

signal health_update(max:int, current:int)

@export var max_health:=100

var health:=max_health:
	set(val):
		if val<0:
			val=0
		health_update.emit(max_health, val)
		health=val
	get():
		return health;

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
var id:int=0
var ships_on_screen:Array[Ship]=[]

func _ready() -> void:
	gun.bullet_spawner.set_multiplayer_authority(id)
	ship_synchronizer.set_multiplayer_authority(id)
	
	Manager.ship_spawned.connect(on_new_ship)
	Manager.ship_despawned.connect(on_ship_exit)
	
	for i in Manager.ships:
		print("lala " + str(i))
		var ship:Ship=Manager.ships[i]
		on_new_ship(ship)
		var calb:=func():
			on_ship_exit(ship)
		Manager.ships[i].tree_exiting.connect(calb)
	
	
	
	
func _physics_process(delta: float) -> void:
	if id != multiplayer.get_unique_id():
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
	var next_rotation := current_rotation.slerp(self.global_transform.basis.get_rotation_quaternion(), delta*pitch_speed)
	camera.basis = Basis(next_rotation)

func _process(delta: float) -> void:
	control.visible = id == multiplayer.get_unique_id()
	camera.current = id == multiplayer.get_unique_id()
	if id != multiplayer.get_unique_id():
		return
			
	if ships_on_screen.is_empty():
		target=null
	
	if Input.is_action_just_pressed("shoot"):
		var direc:=gun.global_position
		if target!=null:
			direc = target.global_position
		gun.shoot(direc)
	
	closest_to_mouse(get_viewport().get_mouse_position())
	
	if target!=null:
		var pos:=camera.unproject_position(target.global_position)
		crosshair.position=lerp(crosshair.position, pos, 0.3)
	else:
		crosshair.position=get_viewport().size/2
	
func on_new_ship(node:Ship) ->void:
	if node != self:
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
		
func on_ship_exit(node:Ship) ->void:
	if node is Ship and node != self:
		ships_on_screen.erase(node)

func closest_to_mouse(pos:Vector2) -> void:
		var closest:Node3D
		var dist:float=INF
		for ship in ships_on_screen:
			var cur_dist:float=pos.distance_squared_to(camera.unproject_position(ship.global_position))
			if cur_dist < dist:
				dist=cur_dist
				closest=ship
		target=closest


func _on_body_entered(body: Node) -> void:
	if id == multiplayer.get_unique_id() and body is Bullet:
		health-=body.damage
		print("got " + str(body.damage) + "damage; health: " + str(health))
		


func _on_health_update(_max: int, current: int) -> void:
	if id == multiplayer.get_unique_id() and current == 0:
		global_position=Vector3(randf_range(-10, 10),randf_range(-10, 10),randf_range(-10, 10))
		health=max_health
		print("died, new health: ", str(health))
		
