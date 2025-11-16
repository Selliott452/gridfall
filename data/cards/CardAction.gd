extends Resource
class_name CardAction

enum CardType { ATTACK, MOVE, OTHER }

@export var name: String = "Unnamed Card"
@export var description: String = ""
@export var cost: int = 1

# for now we just support a single-target attack card.
@export var range: int = 1
@export var damage: int = 3

@export var card_type: CardType = CardType.ATTACK


func play(board: Node, caster: Unit, target_cell: Vector2i) -> bool:
	# Assume it's an attack card and use the board logic
	if not board.combat.can_attack_tile(caster, target_cell):
		print(name, " cannot be played on ", target_cell)
		return false
	
	print("Playing card: ", name, " on ", target_cell)
	board.combat.attack_tile(caster, target_cell)
	return true
