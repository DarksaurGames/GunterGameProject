extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hit_box: Area2D = $HitBox
@onready var wall_detector: RayCast2D = $WallDetector
@onready var ground_detector: RayCast2D = $GroundDetector
@onready var player_detector: RayCast2D = $PlayerDetector
@onready var bone_start_position: Node2D = $BoneStartPosition
@onready var anim_Player: AnimatedSprite2D = $AnimatedSprite2D

enum SkeletonState{
	walk,
	attack,
	dead
}

@export var max_speed = 180.0
@export var aceleration = 400
@export var deceleration = 400
const SPINNING_BONE = preload("uid://02ts24y3xh42") #Faz o preload dessa cena/objeto,
#podendo criar novas instâncias desse objeto, na cena em questão.
const SPEED = 7.0
const JUMP_VELOCITY = -400.0
var status : SkeletonState #Tipagem, indicando que a variável só recebe os valores
						   #do enumerador SkeletonState
var direction = 1
var can_throw = true

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	match status:
		SkeletonState.walk:
			walk_state(delta)
		SkeletonState.attack:
			attack_state(delta)
		SkeletonState.dead:
			dead_state(delta)

	move_and_slide()
	
func go_to_walk_state():
	status = SkeletonState.walk
	anim.play("Walk")
	
func go_to_attack_state():
	status = SkeletonState.attack
	anim.play("Attack")
	velocity = Vector2.ZERO #Zera toda a velocidade, tanto em X quanto em Y, impedindo
							#que o Skeleton se mova na animação Attack.
	can_throw = true
	
func go_to_dead_state():
	status = SkeletonState.dead
	anim.play("Dead")
	hit_box.process_mode = Node.PROCESS_MODE_DISABLED #Desliga o colisor do inimigo,
	#evitando que o player interaja com a sua HitBox, após o mesmo morrer
	
func walk_state(_delta):
	if anim.frame == 3 or anim.frame == 4:
		velocity.x = SPEED * direction #É o quê faz o inimigo andar
	else:
		velocity.x = 0
	
	if wall_detector.is_colliding():
		#anim.flip_h = true
		scale.x *= -1 #Inverte a direção da animação e do RayCast 2D
		direction *= -1 #Inverte a direção de caminhada do Player
		
	if not ground_detector.is_colliding():
		scale.x *= -1
		direction *= -1
		
	if player_detector.is_colliding() && anim_Player.animation != "Dead":
		go_to_attack_state()
		return
		
func attack_state(_delta):
	if anim.frame == 2 && can_throw: #Isso fará ele atirar sempre na hora certa, e com um time bom
		throw_bone()
		can_throw = false
	
func dead_state(_delta):
	velocity.x = 0
	
func take_damage():
	go_to_dead_state()
	
func throw_bone():
	var new_bone = SPINNING_BONE.instantiate() #Cria a instância do objeto, mas não o coloca na cena
	add_sibling(new_bone) #Posiciona o objeto instanciado na cena
	new_bone.position = bone_start_position.global_position #Referencia a posição do próprio BoneStartPosition,
											#para os bones spawnarem dessa localidade
	new_bone.set_direction(self.direction)

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "Attack":
		go_to_walk_state()
		return
