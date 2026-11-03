extends Resource
class_name EnemyData

@export_group("Stats")
@export var max_hp: int = 80
@export var speed: float = 150.0
@export var chase_speed: float = 250.0
@export var knockback_power: float = 500.0

@export_group("AI")
@export var detection_radius: float = 500.0
@export var memory_time: float = 2.0
@export var attack_range: float = 120.0
@export var attack_min_range: float = 80.0
@export var attack_cooldown: float = 1.2
@export var reposition_speed: float = 400.0
@export var reposition_decel: float = 2000.0

@export_group("Combat")
@export var attack_damage: int = 15           # <--- УРОН ВРАГА
@export var damage_variance: float = 0.2      # <--- РАЗБРОС (20%)

@export_group("Visuals")
@export var sprite_texture: Texture2D
@export var sprite_scale: Vector2 = Vector2(1, 1)
