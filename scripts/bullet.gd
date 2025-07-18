extends RigidBody3D

@export var direction:Vector3=Vector3(0,1,0)
@export var speed:float=1

func _on_body_entered(body: Node) -> void:
	queue_free()
	
func _physics_process(delta: float) -> void:
	global_position+=direction*speed*delta
	
