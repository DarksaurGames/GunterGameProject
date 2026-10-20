extends AnimatableBody2D

@onready var target: Sprite2D = $Target

@export var time = 1

func _ready() -> void:
	#var origem = global_position
	#var destino = origem
	#destino.y = 170
	
	target.visible = false
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "global_position", target.global_position, time)#O objeto vai ao destino
	tween.tween_property(self, "global_position", global_position, time) #O objeto volta à sua origem
	tween.set_loops() #Deixa o movimento em loop ou dá uma duração ao mesmo
