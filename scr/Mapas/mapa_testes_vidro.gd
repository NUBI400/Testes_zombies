extends Node3D

@onready var caixa_animation = $Obj/box2/AnimationPlayer

func _ready():
	caixa_animation.play("girando")
