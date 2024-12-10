extends Camera3D



@export var player : Node3D

func _physics_process(delta):
	look_at(Vector3(player.global_position.x, player.global_position.y, player.global_position.z), Vector3.UP)
	
	
	#if player.global_position.x > 0 and player.global_position.z > 0:
		#
