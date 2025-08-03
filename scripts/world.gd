extends Node


@onready var mesh_instance_2d: MeshInstance2D = $MeshInstance2D
var mesh := QuadMesh.new()

func _ready() -> void:
	mesh_instance_2d.mesh = mesh

func _process(_delta: float) -> void:
	var viewport_size = get_viewport().size
	mesh.size = viewport_size
	mesh.center_offset = Vector3(viewport_size.x/2, viewport_size.y/2,0)
