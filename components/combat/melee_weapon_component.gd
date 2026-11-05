extends WeaponComponent
class_name MeleeWeaponComponent

@export var hitbox_offset: float = 60.0
@export var attack_animation: SpriteFrames 
@export var show_animation: bool = false     

@onready var hitbox = $HitboxComponent
@onready var anim_sprite = $AnimatedSprite2D

func _ready():
	if hitbox:
		hitbox.owner_entity = get_parent()
		hitbox.position.x = hitbox_offset
		
	if anim_sprite:
		anim_sprite.visible = false 
		if attack_animation:
			anim_sprite.sprite_frames = attack_animation

# Добавили параметр damage_mult (множитель урона)
func attack(damage_mult: float = 1.0):
	if hitbox:
		var owner_entity = get_parent()
		var damage = 10
		var variance = 0.0
		
		if owner_entity.data:
			damage = owner_entity.data.attack_damage
			variance = owner_entity.data.damage_variance
			
		# Применяем множитель
		damage = int(damage * damage_mult)
			
		var has_custom_anim = (attack_animation != null and show_animation)
		hitbox.activate(0.1, damage, variance, not has_custom_anim)
		
		if has_custom_anim and anim_sprite:
			anim_sprite.visible = true
			anim_sprite.play("default")
			
			var current_anim = anim_sprite
			await current_anim.animation_finished
			if is_instance_valid(current_anim) and current_anim.visible:
				current_anim.visible = false

func cancel_attack():
	if anim_sprite:
		anim_sprite.stop()
		anim_sprite.visible = false
