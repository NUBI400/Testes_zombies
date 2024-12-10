extends CanvasLayer

@onready var CurrentWeaponLabel = $debug_hud/HBoxContainer/CurrentWeapon
@onready var CurrentAmmoLabel = $debug_hud/HBoxContainer2/CurrentAmmo
@onready var CurrentWeaponStack = $debug_hud/HBoxContainer3/WeaponStack

@onready var ROUNDS = $debug_hud/HBoxContainer4
@onready var rounds = $debug_hud/HBoxContainer4/rounds
@onready var rounds_timer = $debug_hud/HBoxContainer4/ROUNDS_timer


@onready var pontos = $debug_hud/HBoxContainer5/Pontos



@onready var Hit_Sight = $Hit_Sight
@onready var Hit_Sight_Timer = $Hit_Sight/Hit_Sight_Timer

@onready var vida = $debug_hud/HBoxContainer6/vida

@onready var preço_armas = $debug_hud/HBoxContainer7
@onready var label = $debug_hud/HBoxContainer7/Label
@onready var pre_o = $"debug_hud/HBoxContainer7/preço"







func _physics_process(delta):
	pontos.text = str(Global.pontos)
	vida.text = str(Global.health_player)
	
	if Global.preço_mp7_visivel == true or Global.preço_shotgun_visivel == true or Global.preço_revolver_visivel == true or Global.preço_medkit_visivel == true:
		preço_armas.visible = true
	else:
		preço_armas.visible = false
	
	
	if Global.preço_mp7_visivel == true:
		pre_o.text = str(Global.preço_mp7)
	if Global.preço_shotgun_visivel == true:
		pre_o.text = str(Global.preço_shotgun)
	if Global.preço_revolver_visivel == true:
		pre_o.text = str(Global.preço_revolver)
	if Global.preço_medkit_visivel == true:
		pre_o.text = str(Global.preço_medkit)

func _on_weapons_manager_update_weapon_stack(WeaponStack):
	CurrentWeaponStack.text = ""
	for i in WeaponStack:
		CurrentWeaponStack.text += "\n"+i

func _on_weapons_manager_update_ammo(Ammo):
	CurrentAmmoLabel.set_text(str(Ammo[0])+" / "+str(Ammo[1]))

func _on_weapons_manager_weapon_changed(WeaponName):
	CurrentWeaponLabel.set_text(WeaponName)


func _on_weapons_manager_hit_successfull():
	Hit_Sight.set_visible(true)
	Hit_Sight_Timer.start()

func _on_hit_sight_timer_timeout():
	Hit_Sight.set_visible(false)


func _on_weapons_manager_add_signal_to_hud(projetil):
	projetil.connect("Hit_Successfull", Callable(self,"_on_weapons_manager_hit_successfull"))


func _on_zumbi_spawn_skibidibitoilete():
	rounds.text = str(Global.Round)
	ROUNDS.set_visible(true)
	rounds_timer.start()

func _on_rounds_timer_timeout():
	ROUNDS.set_visible(false)
