extends WeaponComponent
class_name MeleeWeaponComponent

@onready var hitbox = $HitboxComponent

func _ready():
	if hitbox:
		hitbox.owner_entity = get_parent()

func attack():
	if hitbox:
		var owner_entity = get_parent()
		var damage = 10
		var variance = 0.0
		
		# Если у владельца (игрока или врага) есть дата-файл, берем урон оттуда
		if owner_entity.data:
			damage = owner_entity.data.attack_damage
			variance = owner_entity.data.damage_variance
			
		hitbox.activate(0.1, damage, variance)
