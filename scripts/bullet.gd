class_name Bullet

extends RigidBody3D

@export var target:=Vector3(0,1,0)
@export var speed:float=2
@export var damage:int=5

func _on_body_entered(_body: Node) -> void:
	print("collided")
	queue_free()
	
func _ready() -> void:
		self.look_at(target)
		self.top_level=true
	
func _physics_process(delta: float) -> void:
	global_position+=-global_basis.z*speed*delta
	
