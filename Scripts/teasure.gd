extends Area2D

enum TeasureState{
	open,
	destroy
}
@onready var power_up: Area2D = $"."
@onready var teasure_open_start: Node2D = $TeasureOpenStart
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var status : TeasureState
var POWER_UP = load("res://Entities/power_up.tscn")
var direction = 1
#const COIN = preload("res://Entities/coin.tscn")

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	match status:
		TeasureState.open:
			open_state(delta)
		TeasureState.destroy:
			destroy_state(delta)
			
func go_to_open_state():
	status = TeasureState.open
	anim.play("Open")
	return

func go_to_destroy_state():
	status = TeasureState.destroy
	anim.play("Destroy")
	
func open_state(_delta):
	if anim.frame == 2:
		throw_power_up()
		go_to_destroy_state()
		return
		
func destroy_state(_delta):
	if anim.frame == 3:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player") && anim.frame == 0:
		go_to_open_state()
		return
		
		
func throw_power_up():
	var new_power_up = POWER_UP.instantiate()
	add_sibling(new_power_up)
	new_power_up.position = teasure_open_start.global_position
