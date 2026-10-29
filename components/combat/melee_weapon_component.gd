extends WeaponComponent
class_name MeleeWeaponComponent

@onready var hitbox = $HitboxComponent

func _ready():
	if hitbox:
		# Автоматически передаем владельца (Игрока или Врага) в хитбокс
		hitbox.owner_entity = get_parent()

func attack():
	if hitbox:
		hitbox.activate(0.1)
