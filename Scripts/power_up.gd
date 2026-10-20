extends Area2D

enum PowerState{
	destroy
}
#@onready var teasure_open_start: Node2D = $TeasureOpenStart
@onready var power_up: Area2D = $"."
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
var status : PowerState


func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match status:
		PowerState.destroy:
			destroy_state(delta)
			
func go_to_destroy_state():
	status = PowerState.destroy
	anim.play("Destroy")
	return
	
func destroy_state(_delta):
	if anim.frame == 3:
		power_up.queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		go_to_destroy_state()
		
