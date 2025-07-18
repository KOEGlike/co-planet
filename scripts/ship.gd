extends RigidBody3D

@onready var camera: Camera3D = $Camera3D

const ROTATION_SPEED:=3
const SPEED:=3
const PITCH :=30

const CAMERA_OFFSET :=Vector3(-3, 0, 0)

func _physics_process(delta: float) -> void:
	global_rotation.z=0
	
	var y_axis=-Input.get_axis("left","right")
	rotate_y(y_axis * ROTATION_SPEED * delta)
	
	var z_axis=Input.get_axis("up", "down")    
	var dir :int= -sign(z_axis)
	global_rotation.x=lerp(global_rotation.x, dir * deg_to_rad(PITCH), 0.1)
	
	if Input.is_action_pressed("go"): 
		self.global_position+= -transform.basis.z * SPEED * delta
	
	var camera_position = self.global_position + (CAMERA_OFFSET + -dir * Vector3(0,0.5,0)).rotated(Vector3(0,1,0), self.global_rotation.y+PI/2)
	camera.global_position = lerp(camera.global_position, camera_position, delta*ROTATION_SPEED)
	var current_rotation = Quaternion(camera.global_transform.basis)
	var next_rotation = current_rotation.slerp(Quaternion(self.global_transform.basis), delta*ROTATION_SPEED)
	camera.basis = Basis(next_rotation)
