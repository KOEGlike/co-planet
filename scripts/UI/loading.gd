extends Label

var dots:=1

@export var loading_text="LOADING"
@export var number_of_dots = 3

func _on_timer_timeout() -> void:
	text=loading_text
	dots+=1
	if dots > number_of_dots:
		dots=1
	for _i in dots:
		text+="."
