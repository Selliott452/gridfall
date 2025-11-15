extends Resource
class_name CardAction

@export var name: String = "Unnamed Card"
@export var description: String = ""
@export var cost: int = 1

# for now we just support a single-target attack card.
@export var range: int = 1
@export var damage: int = 3

func play(board: Node, caster: Unit, target_cell: Vector2i) -> void:
	# Assume it's an attack card and use the board logic
	if not board.can_attack_tile(caster, target_cell):
		print(name, " cannot be played on ", target_cell)
		return
	
	print("Playing card: ", name, " on ", target_cell)
	board.attack_tile(caster, target_cell)
