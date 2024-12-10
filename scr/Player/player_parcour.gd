extends CharacterBody3D

@onready var sprite = $Sprite



#States
var walking = false
var sprinting = false
var crouching = false

var morte = false

#wall jump vars
const FLOOR = 0
const JUMP = 1 
const DOWN = 2
var jump_state := FLOOR

#Movement vars
const accel = 90
const FRICTION = 0.85
var crouching_depth = -0.8
var troca_de_velocidade_speed = 5.0
var troca_de_velocidade_correndo_speed = 2.0
var air_lerp_speed = 3
var last_velocity = Vector3.ZERO

var input_dir = Vector2.ZERO

#Input vars
var mouse = Vector2()
var MOUSE_SPEED_PADRAO : float
var MOUSE_SPEED_INSPECION = 0.04
@export var mouse_sens = MOUSE_SPEED_PADRAO 
var direction = Vector3.ZERO

var gravity = 6

#Speed vars
var current_speed = 2.0
var walking_speed = 2.0
var spritin_speed = 4.0


#Jump vars
var jump_velocity = 0.5

@export var jump_power_initial = 1.0
var jump_power = 0
@export var jump_time_max = 0.6
var jump_timer = 0.0

func _physics_process(delta):
	if morte == false:
		input_dir = Input.get_vector("Esquerda", "Direita", "Cima", "Baixo")
		direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x += direction.x * current_speed * delta
			velocity.z += direction.z * current_speed * delta
			
		#movementos
		movement(delta)
		flip()
		gravidade(delta)
		move_and_slide()
		states(delta)
		velocity.x *= FRICTION
		velocity.z *= FRICTION

func states(delta):
	if jump_state == FLOOR:
		_floor(delta)
	elif jump_state == JUMP:
		_jump(delta)
	elif jump_state == DOWN:
		_down()



func movement(delta):
	
	if jump_state == FLOOR:
		direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta*troca_de_velocidade_speed)
		if direction.x != 0 or direction.z != 0:
			sprite.play("walk")
			if Input.is_action_pressed("Sprint"):
				current_speed =lerp(current_speed, spritin_speed, delta*troca_de_velocidade_speed)
			else:
				current_speed =lerp(current_speed, walking_speed, delta*troca_de_velocidade_speed)
		
		else:
			sprite.play("idle")
			
		
	else:
		if input_dir != Vector2.ZERO:
			direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta*air_lerp_speed)





func flip():
	if velocity.x > 0:
		sprite.flip_h = false
	if velocity.x < 0:
		sprite.flip_h = true

func gravidade(delta):
	
	if not is_on_floor():
		velocity.y -= gravity * delta 


func _floor(delta):
	if is_on_floor():   # VERIFICA SE ESTA NO CHAO E ZERA O TIMER
		jump_timer = 0.0
	else:
		jump_state = DOWN
	
	if Input.is_action_just_pressed("jump"):  #PULAR
		jump_timer = 0.0
		jump_state = JUMP

func _jump(delta):
	sprite.play("jump1")
	
	print(jump_timer)
	jump_timer += delta
	
	if jump_timer >= jump_time_max:
		jump_state = DOWN
	
	apply_jump_force(jump_power_initial)
	jump_power = jump_power_initial
	
	if Input.is_action_pressed("jump") && jump_timer < jump_time_max: 
		jump_power += jump_velocity
		apply_jump_force(jump_power)
	
	if Input.is_action_just_released("jump"):
		jump_timer = jump_time_max


func _down():
	sprite.play("jump2")
	
	if is_on_floor():   # VERIFICA SE ESTA NO CHAO E ZERA O TIMER
		jump_state = FLOOR


func apply_jump_force(power):
	velocity.y = power
