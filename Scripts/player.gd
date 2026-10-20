extends CharacterBody2D

enum PlayerState{ #Enumerador
	idle, #1
	walk, #2
	jump, #3
	fall, #4
	duck, #5
	slide,#6
	wall, #7
	swimming, #8
	dead #9
	}
@onready var player: CharacterBody2D = $"."
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
#Arrastar da árvore de nós e pressionar CTRL na hora de soltar o nó no código
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hit_box: Area2D = $HitBox
@onready var reload_timer: Timer = $ReloadTimer
@onready var hitbox_collision_shape: CollisionShape2D = $HitBox/CollisionShape2D
@onready var left_wall_detector: RayCast2D = $LeftWallDetector
@onready var right_wall_detector: RayCast2D = $RightWallDetector


@export var max_speed = 180.0
@export var aceleration = 400
@export var deceleration = 400
@export var slide_desaceleration = 100
@export var max_jump_count = 1 #@export torna essa variável modificável no Inspetor do nó
@export var wall_acceleration = 40
@export var wall_jump_velocity = 140
@export var water_max_speed = 100
@export var water_acceleration = 200

const JUMP_VELOCITY = -300.0
var status: PlayerState #var status só receberá valores do Enumerador
var direction = 0 #Deve torná-la global, para as funções move() e update_direction() terem acesso à mesma
var jump_count = 0

func _ready() -> void:
	go_to_idle_state()

func _physics_process(delta: float) -> void:


	
	match status: #Mesma função do Switch, ele fica analisando uma escolha
		PlayerState.idle:  #buscando detectá-la
			idle_state(delta)
		PlayerState.walk:
			walk_state(delta)
		PlayerState.jump:
			jump_state(delta)
		PlayerState.fall:
			fall_state(delta)
		PlayerState.duck:
			duck_state(delta)
		PlayerState.slide:
			slide_state(delta)
		PlayerState.wall:
			wall_state(delta)
		PlayerState.swimming:
			swimming_state(delta)
		PlayerState.dead:
			dead_state(delta)
			
	move_and_slide() #Aqui é onde o código calcula o posicionamento do player
	#de acordo com a ação da gravidade
			
func go_to_idle_state(): #Essas funções só ocorrem uma vez e são responsáveis
	status = PlayerState.idle	#por preparar a ativação das abaixo
	anim.play("Idle")
	
func go_to_walk_state():
	status = PlayerState.walk
	anim.play("Walk")
	
func go_to_jump_state():
	status = PlayerState.jump
	anim.play("Jump")
	velocity.y = JUMP_VELOCITY
	jump_count += 1
	
func go_to_fall_state():
	status = PlayerState.fall
	anim.play("Fall")
	
func go_to_duck_state():
	status = PlayerState.duck
	anim.play("Duck")
	set_small_collider()

func exit_from_duck_state():
	set_large_collider()
	
func go_to_slide_state():
	status = PlayerState.slide
	anim.play("Slide")
	set_small_collider()
	
func exit_from_slide_state():
	set_large_collider()
	
func go_to_wall_state():
	status = PlayerState.wall
	anim.play("Wall")
	velocity = Vector2.ZERO
	jump_count = 0 #Zerando esse valor, o contador de pulos reinicia ao tocarmos na parede, 
				   #no modo Wall, o quê permite dar o pulo duplo após pular em uma parede
	
func go_to_swimming_state():
	status = PlayerState.swimming
	anim.play("Swimming")
	velocity.y = min(velocity.y, 150)
	return

func go_to_dead_state():
	
	if status == PlayerState.dead:
		return
		
	status = PlayerState.dead
	anim.play("Dead")
	velocity.x = 0 #Zera toda a velocidade, tanto em X quanto em Y, impedindo
							#que o Player escorregue na animação Dead.
	hit_box.queue_free()
	reload_timer.start() #Wait Time é o tempo, em segundos, que o timer vai contabilizar
						 #One Shot indica que o Timer vai ocorrer uma vez a cada Wait Time
	#Quando o Player morre, o Timer começa
	
func idle_state(delta): #Essas funções ocorrem eternamente quando são começadas
	apply_gravity(delta)
	move(delta)
		
	if Input.is_action_just_pressed("up"): #Verifica no momento que a pessoa apertou
		go_to_jump_state()
		return
		
	if velocity.x != 0:
		go_to_walk_state()
		return #Permite que o código faça cada processamento separadamente, sem loop infinito
		
	if Input.is_action_pressed("duck"): #Verifica se já está apertado
		go_to_duck_state()
		return
		
func walk_state(delta):
	apply_gravity(delta)
	move(delta)
	if velocity.x == 0:
		go_to_idle_state()
		return
		
	if Input.is_action_just_pressed("up"):
		go_to_jump_state()
		
	if !is_on_floor():
		jump_count += 1 #Ao cair, consome um pulo, só tendo mais um para fazer
		go_to_fall_state() #Caso esteja no chão e pule normaml, terá a quantidade padrão de pulos
		return
		
	if Input.is_action_just_pressed("duck"):
		go_to_slide_state()
		return
	
func jump_state(delta):
	apply_gravity(delta)
	move(delta)
	
	if Input.is_action_just_pressed("up") && can_jump():
		go_to_jump_state()
		return
		
	if velocity.y > 0:
		go_to_fall_state()
		return
	
func fall_state(delta):
	apply_gravity(delta)
	move(delta)
	
	if Input.is_action_just_pressed("up") && can_jump():
		go_to_jump_state()
		return
	
	if is_on_floor():
		jump_count = 0
		if velocity.x == 0:
			go_to_idle_state()
		else:
			go_to_walk_state()		
		return 
	
	if (left_wall_detector.is_colliding() or right_wall_detector.is_colliding()) && is_on_wall():
		go_to_wall_state()
		return
	
func duck_state(delta):
	apply_gravity(delta)
	update_direction()
	if Input.is_action_just_released("duck"):
		exit_from_duck_state()
		go_to_idle_state()
		return
		
func slide_state(delta):
	apply_gravity(delta)
	velocity.x = move_toward(velocity.x, 0, slide_desaceleration * delta)
	
	if Input.is_action_just_released("duck"):
		exit_from_slide_state()
		go_to_walk_state()
		return
		
	if velocity.x == 0:
		exit_from_slide_state()
		go_to_duck_state()
		return
		
func wall_state(delta):
	
	velocity.y += wall_acceleration * delta
	
	if left_wall_detector.is_colliding():
		anim.flip_h = false
		direction = 1
	elif right_wall_detector.is_colliding():
		anim.flip_h = true
		direction = -1
	else:
		go_to_fall_state()
		return
	
	if is_on_floor():
		go_to_idle_state()
		return
		
	if Input.is_action_just_pressed("up"):
		velocity.x = wall_jump_velocity * direction
		go_to_jump_state()
		return
	
func swimming_state(delta):
	update_direction()
	if direction:
		velocity.x = move_toward(velocity.x, water_max_speed * direction, wall_acceleration * delta)#Se multiplicar por direction, quando a direção
									 #for -1, o player será obrigado a ir para a esquerda.
	else:
		velocity.x = move_toward(velocity.x, 0, water_acceleration * delta)
		
	var vertical_direction = Input.get_axis("up","duck")
	if vertical_direction:
		velocity.y = move_toward(velocity.y, water_max_speed * vertical_direction, water_acceleration * delta)
	else:
		velocity.y = move_toward(velocity.y, 0, 200 * delta)
	
func dead_state(delta):
		apply_gravity(delta)
		
func move(delta):
#Segundo Bloco: Dá a velocidade, se Input, dando o movimento ao Player
	update_direction()
	if direction:
		velocity.x = move_toward(velocity.x, direction * max_speed, aceleration * delta) #O terceiro incrementa,
		#fazendo o mesmo acelerar com 5 segundos após apertar na tecla, trazendo uma pequena demora
		#para começar a acelerar.
		
		#velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration * delta) #O terceiro decrementa 5, 
		#fazendo ele ir "parando" em 5 segundos, o quê o faz deslizar
		
func apply_gravity(delta):
	#delta é o tempo que passou desde o último frame
	if not is_on_floor():
		velocity += get_gravity() * delta #Aqui é onde se aplica a gravidade
		
func update_direction():
	#Primeiro Bloco: Pega a direção e aplica o flip
	direction = Input.get_axis("left", "right")
	
	if direction < 0:
		anim.flip_h = true
	elif direction > 0:
		anim.flip_h = false
		
func can_jump() -> bool:
	return jump_count < max_jump_count
	
func set_small_collider():
	collision_shape.shape.radius = 5
	collision_shape.shape.height = 10
	collision_shape.position.y = 3
	
	hitbox_collision_shape.shape.size.y = 3
	hitbox_collision_shape.position.y = 6.5
	
func set_large_collider():
	collision_shape.shape.radius = 6
	collision_shape.shape.height = 16
	collision_shape.position.y = 0
	
	hitbox_collision_shape.shape.size.y = 15
	hitbox_collision_shape.position.y = 0.5

func _on_hit_box_area_entered(area: Area2D) -> void:#Analisa quando uma Area/HitBox invade a outra
	if area.is_in_group("Enemy"):
		hit_enemy(area)		
	elif area.is_in_group("LethalArea"):
		hit_lethal_area(area)
	elif area.is_in_group("PowerUp"):
		max_jump_count += 1
		
func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("LethalArea"):
		go_to_dead_state()
	elif body.is_in_group("Water"):
		go_to_swimming_state()

func hit_enemy(area: Area2D):
	if velocity.y > 0:
		#inimigo morre
		area.get_parent().take_damage() #Acessar o Skeleton inteiro, não só a HitBox, e o apaga por completo
		go_to_jump_state()
		#Warning: Para a função area.get_parent() funcionar e acessar determinado pai
		#de uma determinada HitBox, você deve selecionar a HitBox primeiro, antes 
		#de escrever o código da area. Caso contrário, o código notificará um erro.
	else:
		#go_to_dead_state() -->Player morre
		#if status != PlayerState.dead: #Quando o Player entra em contato com a HitBox do inimigo
									   #e não está morto, ele chama o estado de morte, mas
									   #quando ele detectou a HitBox do inimigo e já está morto,
									   #a animação de morte não será chamada novamente
			go_to_dead_state()

func hit_lethal_area(_area: Area2D):
	go_to_dead_state()

func _on_reload_timer_timeout() -> void:
		get_tree().reload_current_scene() #Quando o Timer termina, a cena em questão é reiniciada


func _on_hit_box_body_exited(body: Node2D) -> void:
	if body.is_in_group("Water"):
		go_to_jump_state()
