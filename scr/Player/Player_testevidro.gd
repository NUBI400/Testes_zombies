extends CharacterBody3D

# Player nodes
@onready var camera_3d = $Nek/Head/Eyes/Camera3D
@onready var nek = $Nek
@onready var eyes = $Nek/Head/Eyes
@onready var head = $Nek/Head
@onready var standing_collision_shape = $Standing_collision_shape
@onready var crouching_collision_shape = $Crouching_collision_shape

#@onready var animation_player = $Nek/Head/Eyes/AnimationPlayer
@onready var corpo = $Corpo
@onready var area_dead = $area_dead


#raycasts
@onready var ray_cast_3d = $raycasts/RayCast3D
@onready var ray_cast_3d_2 = $raycasts/RayCast3D2
@onready var ray_cast_3d_3 = $raycasts/RayCast3D3
@onready var ray_cast_3d_4 = $raycasts/RayCast3D4
@onready var ray_cast_3d_5 = $raycasts/RayCast3D5


#shaders
@onready var subimerso_shader = $Shaders/Subimerso
@onready var analoghorrorshaders = $Shaders/Analoghorrorshaders


@onready var interaction = $Nek/Head/Eyes/Camera3D/interaction
@onready var hand = $Nek/Head/Eyes/Camera3D/hand
@onready var joint = $Nek/Head/Eyes/Camera3D/joint
@onready var staticbody = $Nek/Head/Eyes/Camera3D/staticbody





# Estados visual
#const PLAYER_AGACHADO = preload("res://Player/playerAGACHADO.tres")
#const PLAYER_EMPE = preload("res://Player/playerEMPE.tres")
#
#const PLAYER_AGACHADO_AREA = preload("res://Player/player_agachado_area.tres")
#const PLAYER_EMPE_AREA = preload("res://Player/player_empe_area.tres")


#vida
var health_back_become = false

#LANTERNA
const FLASHLIGHT_FOLLOW_SPEED = 15.0



#VARIAVEIS DENTRO DAGUA
var AGUA_VISIBLE : FogVolume 
var dentrodaqua = false
var agua_velocityY = 4
var pode_nadar = true


#Speed vars
var current_speed = 40.0
var walking_speed = 40.0
var sprinting_speed = 80.0
var crouching_speed = 20.0
var flying_speed = 20.0
var subimerso_speed = 20.0


#States
var walking = false
var sprinting = false
var crouching = false
var voando = false

var morte = false

#Jump vars
var jump_velocity = 7.0

#wall jump vars
const FLOOR = 0
const WALL = 1
const AIR = 2
var current_state := AIR



#Head boobing vars
var head_bobbing_sprinting_speed = 22.0
var head_bobbing_walking_speed = 14.0
var head_bobbing_crouching_speed= 10.0

var head_bobbing_sprinting_intensity = 0.4
var head_bobbing_walking_intensity  = 0.2
var head_bobbing_crouching_intensity = 0.1

var head_bobbing_vector = Vector2.ZERO
var head_bobbing_index = 0.0
var head_bobbing_current_intensity = 0.0


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

var gravity = 14

@export var mirrored = false
@export var Mirror_What : CharacterBody3D



var picked_object
var pull_power = 4


var rotation_power = 0.1
var locked = false



func _ready():
	analoghorrorshaders.visible = false
	subimerso_shader.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	head.rotation.x = 0
	standing_collision_shape.disabled = false
	crouching_collision_shape.disabled = true


func _physics_process(delta):
	if mirrored == false:
		if morte == false:
			input_dir = Input.get_vector("Esquerda", "Direita", "Cima", "Baixo")
			direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			if direction:
				velocity.x += direction.x * current_speed * delta
				velocity.z += direction.z * current_speed * delta
			
			_pick_up()
			Global.Player_Pos = position
			health_back()
			#movementos
			movement(delta)
			Crouch_and_slide(delta)
			jump()
			
			gravidade(delta)
			move_and_slide()
			update_state()
			velocity.x *= FRICTION
			velocity.z *= FRICTION
		
		# ENTRAR NO MODO COMPUTADOR
			#if Input.is_action_just_pressed("action"):
				#if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
					#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
					#mouse_sens = MOUSE_SPEED_INSPECION
				#else:
					#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
					#mouse_sens = MOUSE_SPEED_PADRAO
			#mouse = Vector2()
	else:
		position.y = Mirror_What.get_position().y
		position.z = Mirror_What.get_position().z
		position.x = Mirror_What.get_position().x * -1
		rotation.y = Mirror_What.rotation.y * -1
		rotation.z = Mirror_What.rotation.z
		head.rotation.x = Mirror_What.head.rotation.x 
		

func _input(event):
	
	if !locked:
		if mirrored == false:
			if event is InputEventMouseMotion:
				mouse = event.relative
				rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
				head.rotate_x(deg_to_rad(-event.relative.y* mouse_sens))
				head.rotation.x = clamp(head.rotation.x,deg_to_rad(-80),deg_to_rad(90))
	
	
	if Input.is_action_just_pressed("action"):
		if picked_object == null:
			pick_object()
		
	if Input.is_action_just_released("action"):
		remove_object()
		
	if Input.is_action_pressed("Reload"):
		locked = true
		rotate_object(event)
		
	if Input.is_action_just_released("Reload"):
		locked = false
	
	if Input.is_action_just_pressed("mouse2"):
		if picked_object != null:
			var knockback = picked_object.global_position - global_position
			picked_object.apply_central_impulse(knockback * 5)
			remove_object()
	
func movement(delta):
	
	if is_on_floor():
		direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta*troca_de_velocidade_speed)
	else:
		if input_dir != Vector2.ZERO:	
			direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta*air_lerp_speed)

func gravidade(delta):
	
	if not is_on_floor():
		velocity.y -= gravity * delta 

func jump():
	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if current_state == FLOOR and dentrodaqua == false:
			velocity.y = jump_velocity
			#animation_player.play("Jump")
		
	if Input.is_action_pressed("jump") and dentrodaqua and pode_nadar:
		velocity.y = agua_velocityY
		pode_nadar = false
		await get_tree().create_timer(1).timeout
		pode_nadar = true
	
	
	#Handle Landing
	#if is_on_floor(): 
		#if last_velocity.y < -10.0:
			#animation_player.play("Roll")
		#elif  last_velocity.y < -4.0:
			#animation_player.play("Landing")

func Crouch_and_slide(delta):
	if Input.is_action_pressed("Crouch") and dentrodaqua == false:
		current_speed = lerp(current_speed,crouching_speed, delta*troca_de_velocidade_speed)
		analoghorrorshaders.visible = true
		head.position.y =lerp( head.position.y, 0.0 + crouching_depth, delta * troca_de_velocidade_speed)
		standing_collision_shape.disabled = true
		crouching_collision_shape.disabled = false

		
		walking = false
		sprinting = false
		crouching = true
	elif !ray_cast_3d.is_colliding() or !ray_cast_3d_2.is_colliding() or !ray_cast_3d_3.is_colliding() or !ray_cast_3d_4.is_colliding() or !ray_cast_3d_5.is_colliding():
	#Standing
		head.position.y =lerp( head.position.y, 0.0 , delta * troca_de_velocidade_speed)
		analoghorrorshaders.visible = false
		standing_collision_shape.disabled = false
		crouching_collision_shape.disabled = true


	
	#Sprinting
		if Input.is_action_pressed("Sprint") and dentrodaqua == false and input_dir.y != 1:
			current_speed =  lerp(current_speed,sprinting_speed, delta*troca_de_velocidade_correndo_speed)
			walking = false
			sprinting = true
			crouching = false
	#Walking
		else:
			if dentrodaqua == false:
				current_speed =lerp(current_speed, walking_speed, delta*troca_de_velocidade_speed)
				walking = true
				sprinting = false
				crouching = false
	
	if dentrodaqua:
		current_speed = lerp(current_speed, subimerso_speed, delta*troca_de_velocidade_speed)
		if Input.is_action_pressed("Crouch"):
			velocity.y = -agua_velocityY
	
	
	
	# Handle headbob
	if sprinting:
		head_bobbing_current_intensity = head_bobbing_sprinting_intensity
		head_bobbing_index += head_bobbing_sprinting_speed*delta
	elif walking:
		head_bobbing_current_intensity = head_bobbing_walking_intensity
		head_bobbing_index += head_bobbing_walking_speed*delta
	elif crouching:
		head_bobbing_current_intensity = head_bobbing_crouching_intensity
		head_bobbing_index += head_bobbing_crouching_speed*delta
			
	
	
	if is_on_floor() && input_dir != Vector2.ZERO:
		head_bobbing_vector.y = sin(head_bobbing_index)
		head_bobbing_vector.x = sin(head_bobbing_index/2)+ 0.5
		eyes.position.y = lerp(eyes.position.y, head_bobbing_vector.y*(head_bobbing_current_intensity /2.0), delta*troca_de_velocidade_speed)
		eyes.position.x = lerp(eyes.position.x, head_bobbing_vector.x*(head_bobbing_current_intensity), delta*troca_de_velocidade_speed)
		
	else:
		eyes.position.y = lerp(eyes.position.y,0.0, delta*troca_de_velocidade_speed)
		eyes.position.x = lerp(eyes.position.x, 0.0, delta*troca_de_velocidade_speed)

func update_state():
	if is_on_wall_only():
		current_state = WALL
	elif is_on_floor():
		current_state = FLOOR
	else:
		current_state = AIR



func health_back():
	if health_back_become:
		health_back_become = false
		Global.health_player += 1


func _on_area_dead_area_entered(area):
	if area.is_in_group("damage"):
		Global.health_player -= 1
		if Global.health_player <= 0:
			get_tree().quit()
		await get_tree().create_timer(60).timeout 
		health_back_become = true

func _pick_up():
	if picked_object != null:
		var a = picked_object.global_transform.origin
		var b = hand.global_transform.origin
		picked_object.set_linear_velocity((b-a)*pull_power)


func pick_object():
	var collider = interaction.get_collider()
	if collider != null and collider is RigidBody3D:
		picked_object = collider
		joint.set_node_b(picked_object.get_path())
func remove_object():
	if picked_object != null:
		picked_object = null
		joint.set_node_b(joint.get_path())


func rotate_object(event):
	if picked_object != null:
		if event is InputEventMouseMotion:
			staticbody.rotate_x(deg_to_rad(event.relative.y * rotation_power))
			staticbody.rotate_y(deg_to_rad(event.relative.x * rotation_power))












