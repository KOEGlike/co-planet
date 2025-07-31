extends VBoxContainer

func add_label(id:int) -> void:
	var label=Label.new()
	label.name=str(id)
	label.text=Manager.players[id]["name"]
	self.add_child(label)

func _ready() -> void:
	Manager.player_connected.connect(func(id, _info):
		add_label(id)	
	)
	
	for id in Manager.players:
		add_label(id)
