extends CharacterBody3D



var medidor = 1
var player_in_area = false


var accel = 10

var direction_player = 0 

var Health = 40

@export var Player : CharacterBody3D 

@onready var nav = $NavigationAgent3D
@onready var animation_player = $Sketchfab_Scene/Sketchfab_model/Root/Armature/Skeleton3D/AnimationPlayer

@onready var damage_area = $damage_area
@onready var damage_area_colision = $damage_area/CollisionShape3D

@onready var attack_anim = $AnimationPlayer

func _ready():
	Global.InimigosRound += 1


func _physics_process(delta):
	animation_player.play("Take 01")
	var direction = Vector3()
	
	
	if Health <= 0:
		Global.InimigosRound -= 1
		Global.pontos += 5
		queue_free()
		if Global.InimigosRound <= 0: 
			Global.ContagemInimigos += 1
	
	direction = nav.get_next_path_position() - global_position
	direction = direction.normalized()
	
	nav.target_position = Global.Player_Pos
	

	velocity = velocity.lerp(direction * Global.speed, accel * delta) * medidor
	
	look_at(Vector3(Global.Player_Pos.x, global_position.y, Global.Player_Pos.z), Vector3.UP)
	
	gravidade(delta)
	
	move_and_slide()


func gravidade(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= Global.gravity * delta

func Hit_Successful(Damage, _Direction: Vector3 = Vector3.ZERO, _Position: Vector3 = Vector3.ZERO):
	var Hit_Position = _Position - get_global_transform().origin 
	Health -= Damage
	Global.pontos += 1





func _on_area_area_entered(area):
	if area.is_in_group("Player"):
		player_in_area = true
		while player_in_area:
			medidor = 0
			attack_anim.queue("Attack")
			await get_tree().create_timer(1).timeout
			medidor = 1

func _on_area_area_exited(area):
	if area.is_in_group("Player"):
		player_in_area = false





