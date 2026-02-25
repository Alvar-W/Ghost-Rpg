extends Resource
class_name BattleUnit

var robot: RobotData = null
var spirit: SpiritData

var max_hp: int
var current_hp: int
var attack: float
var defense: int
var speed: int
var accuracy: float
var mana_max: int
var mana: int
var element: String
var weaknesses: Array[String]
var resistances: Array[String]
var initiative: float


# Player unit (robot + spirit)
func _init(r: RobotData, s: SpiritData):
	robot = r
	spirit = s
	_build_from_spirit_and_robot()

# Enemy unit (spirit only)
static func from_spirit(s: SpiritData) -> BattleUnit:
	var u = BattleUnit.new(null, s)
	return u

func _build_from_spirit_and_robot():
	max_hp = (robot.base_hp if robot else 0) + spirit.hp_mod
	current_hp = max_hp

	attack = 1.0 * spirit.damage_mod
	defense = robot.defense if robot else 0
	speed = (robot.speed if robot else 0) + spirit.speed_mod
	accuracy = spirit.accuracy
	mana_max = spirit.mana_max
	mana = mana_max

	element = spirit.element
	weaknesses = spirit.weaknesses.duplicate()
	resistances = spirit.resistances.duplicate()
