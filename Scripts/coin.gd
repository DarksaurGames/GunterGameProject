extends Area2D

enum CoinState{
	idle,
	destroy
}

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var coin: Area2D = $"."

var status : CoinState

func _ready() -> void:
	go_to_idle_state()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	match status:
		CoinState.idle:
			idle_state(delta)
		CoinState.destroy:
			destroy_state(delta)

func go_to_idle_state():
	status = CoinState.idle
	anim.play("Idle")
	
func go_to_destroy_state():
	status = CoinState.destroy
	
func idle_state(_delta):
	pass
	
func destroy_state(_delta):
	anim.play("Destroy")
	if anim.frame == 3:
		coin.queue_free()
	
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		go_to_destroy_state()
		
