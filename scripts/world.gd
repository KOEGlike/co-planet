extends Node

@onready var mesh_instance_2d: MeshInstance2D = $MeshInstance2D


func _process(_delta: float) -> void:
	var mesh=QuadMesh.new()
	#mesh.size=get_viewport().size
	#mesh.center_offset=mesh.size/2
	#mesh_instance_2d.mesh
	#get_viewport().size
