class_name Ship

extends RigidBody3D

@export_category("camera")
@export var camera_offset :=Vector3(-3, 1, 2)
@export var camera_fov:float=90.0
@export var camera_fov_speed:float =1

@export_category("speeds")
@export var rotation_speed:=3
@export var pitch_speed:=5
@export var speed:=10
@export var pitch :=30

@export_category("targeting")
var distance_to_mouse_to_target:=150
var distance_to_mouse_to_detarget:=200
var crosshair_color_neutral:=Color.from_rgba8(255,255,255)
var crosshair_color_targeting:=Color.from_rgba8(255,0,0)

@export var max_health:=100

@onready var camera: Camera3D = $Camera3D
@onready var gun: Gun = $Gun
@onready var crosshair: Sprite2D = $Control/Crosshair
@onready var control: Control = $Control
@onready var ship_synchronizer: MultiplayerSynchronizer = $ShipSynchronizer
@onready var label_3d: Label3D = $Label3D
@onready var sprite_3d: Sprite3D = $Sprite3D

signal health_update(max:int, current:int)

var contact_damage=3

var dir:float=0
var id:int=0
var ships_on_screen:Array[Ship]=[]
var target:Node3D=null

var health:
	set(val):
		print("setting health to ", str(val))
		if val<0:
			val=0
			print("adjusted helath: ", str(val))
		health_update.emit(max_health, val)
		health=val
	get():
		return health;

func _ready() -> void:
	health=max_health
	
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
		
	label_3d.text=Manager.players[id]["name"]
	
	if id == multiplayer.get_unique_id():
		sprite_3d.visible=false
		label_3d.visible=false
	
	
	
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
	
	select_target(get_viewport().get_mouse_position())
	
	if target!=null:
		var pos:=camera.unproject_position(target.global_position)
		crosshair.position=lerp(crosshair.position, pos, 0.3)
		
		crosshair.modulate=crosshair_color_targeting
	else:
		crosshair.position=get_viewport().size/2
		crosshair.modulate=crosshair_color_neutral
	
func on_new_ship(node:Ship) ->void:
	if node != self:
		var ship:Ship=node
		var visibility:VisibleOnScreenNotifier3D=ship.get_node("VisibleOnScreen")
		
		var on_ship_entered_screen:=func():
			ships_on_screen.append(ship)
			print(ship.name + " entered")
			print(ships_on_screen)
		visibility.screen_entered.connect(on_ship_entered_screen)
		
		var on_ship_exited_screen:=func():
			ships_on_screen.erase(ship)
			print(ship.name + "exited")
			print(ships_on_screen)
		visibility.screen_exited.connect(on_ship_exited_screen)
		
func on_ship_exit(node:Ship) ->void:
	if node is Ship and node != self:
		ships_on_screen.erase(node)

func select_target(pos:Vector2) -> void:
	var closest:Node3D
	var dist:float=INF
	for ship in ships_on_screen:
		var cur_dist:float=pos.distance_to(camera.unproject_position(ship.global_position))
		if cur_dist < dist:
			dist=cur_dist
			closest=ship
	if target!=closest and dist<=distance_to_mouse_to_target:
		target=closest
		
	if dist>distance_to_mouse_to_detarget:
		target=null	
		
	


func _on_body_entered(body: Node) -> void:
	if not id == multiplayer.get_unique_id():
		return
		
	var damage
	if body is Bullet:
		damage=body.damage
	elif body is Ship:
		damage=body.contact_damage
	else:
		damage=1
		
	print("health before damage: ",str(health))
	health-=damage
	print("got " + str(damage) + "damage; health: " + str(health))
		
	if health<=0:
		global_position=Vector3(randf_range(-10, 10),randf_range(-10, 10),randf_range(-10, 10))
		health=max_health
		print("died, new health: ", str(health))



		
		
		
