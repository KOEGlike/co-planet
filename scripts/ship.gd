class_name Ship

extends RigidBody3D

@onready var camera: Camera3D = $Camera3D
@onready var gun: Gun = $Gun
@onready var ships: Node = %Ships
@onready var crosshair: Sprite2D = $Crosshair

const ROTATION_SPEED:=3
const PITCH_SPEED=5
const SPEED:=10
const PITCH :=30

@export var CAMERA_OFFSET :=Vector3(-3, 1, 2)
@export var camera_fov:float=90.0
@export var camera_fov_speed:float =1

var dir:float=0

var ships_on_screen:Array[Ship]=[]

@export var target:Node3D=null

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

func _ready() -> void:
	ships.child_entered_tree.connect(on_new_ship)
	for child in ships.get_children():
		on_new_ship(child)
	
func _physics_process(delta: float) -> void:
	global_rotation.z=0
	
	var y_axis:=-Input.get_axis("left","right")
	rotate_y(y_axis * ROTATION_SPEED * delta)
	
	var z_axis:=Input.get_axis("up", "down")    
	dir=-z_axis
	global_rotation.x=lerp(global_rotation.x, dir * deg_to_rad(PITCH), 0.1)
	
	if Input.is_action_pressed("go"): 
		self.global_position+= -transform.basis.z * SPEED * delta
		camera.fov=lerp(camera.fov, camera_fov+ self.linear_velocity.length() * camera_fov_speed, 0.1)
	else :
		camera.fov=lerp(camera.fov, camera_fov, 0.1)
		
	if Input.is_action_just_pressed("shoot"):
		var dir:=gun.global_position
		if target!=null:
			dir = target.global_position
		gun.shoot(dir)
	
	
	var camera_position := self.global_position + (CAMERA_OFFSET + -dir * Vector3(0,0.5,0)).rotated(Vector3(0,1,0), self.global_rotation.y+PI/2)
	camera.global_position = lerp(camera.global_position, camera_position, delta*ROTATION_SPEED)
	
	var current_rotation := Quaternion(camera.global_transform.basis)
	var next_rotation := current_rotation.slerp(Quaternion(self.global_transform.basis), delta*PITCH_SPEED)
	camera.basis = Basis(next_rotation)

func _process(delta: float) -> void:
	#print(ships_on_screen.is_empty())
	if !ships_on_screen.is_empty():
		var ship:=ships_on_screen[0]
		target=ship
		
		var pos:=camera.unproject_position(ship.global_position)
		crosshair.position=lerp(crosshair.position, pos, 0.3)
	else:
		target=null
		crosshair.position=get_viewport().size/2
	crosshair.visible=camera.current

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		event.position
