extends VBoxContainer

func add_label(id:int) -> void:
	var label=Label.new()
	label.name=str(id)
	label.text=Manager.players[id]["name"] + " not ready"
	self.add_child(label)
	
func update_label(id):
	for child in self.get_children():
		if child is Label and child.name==str(id):
			var child_label:Label=child
			child_label.text=Manager.players[id]["name"] + " ready"

		

func _ready() -> void:
	Manager.player_connected.connect(func(id, _info):
		add_label(id)	
	)
	
	Manager.player_ready.connect(update_label)
	
	for id in Manager.players:
		add_label(id)
