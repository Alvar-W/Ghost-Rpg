extends ItemData
class_name SpiritData

@export var hp_mod: int
@export var damage_mod: float
@export var speed_mod: int
@export var element: String
@export var accuracy: float
@export var mana_max: int
@export var special_attacks: Array[String]
@export var weaknesses: Array[String]
@export var resistances: Array[String]
@export var environment_bonus: Dictionary # biome -> multiplier
