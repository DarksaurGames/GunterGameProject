extends Area2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var speed = 60
var direction = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += speed * delta * direction #O osso se desloca 1 pixel/ 1 posição por segundo,
											#o quê implica em aumentar o valor da velocidade, caso contrário,
											#vai ficar muito lenta a movimentação. Ex: 5 FPS = 5 pixels por segundo

func set_direction(skeleton_direction):
	self.direction = skeleton_direction
	anim.flip_h = direction < 0 #Se o Skeleton virar pra direita, o ossinho inverterá sua direção


func _on_self_destruct_timer_timeout() -> void:
	queue_free() #Comando para destruir o objeto e liberar memória


func _on_area_entered(_area: Area2D) -> void: #Quando o bone bate na Area HitBox do Player
	queue_free()


func _on_body_entered(_body: Node2D) -> void: #Quando o bone bate em algo que não tem Area
	queue_free()
