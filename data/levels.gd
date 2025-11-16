extends Node
class_name Levels

# Each string row is a row of the map.
# Legend:
#  # = wall
#  . = floor
#  P = player start
#  E = enemy start
#    = treated as wall/outside

const LEVELS := [
	[   # Level 0 - simple arena with a pillar
		"##########",
		"#..P....E#",
		"#..##....#",
		"#........#",
		"##########",
	],
	[   # Level 1 - narrow corridor
		"########",
		"#P....E#",
		"####..##",
		"#......#",
		"########",
	],
]

static func get_level(index: int) -> Dictionary:
	var map_rows = LEVELS[index]
	var height = map_rows.size()
	var width = map_rows[0].length()

	var walls: Array[Vector2i] = []
	var player_start := Vector2i.ZERO
	var enemy_starts: Array[Vector2i] = []

	for y in range(height):
		var row = map_rows[y]
		for x in range(width):
			var c = row[x]
			var cell := Vector2i(x, y)
			match c:
				'#', ' ':
					walls.append(cell)
				'P':
					player_start = cell
				'E':
					enemy_starts.append(cell)
				'.':
					pass
				_:
					pass

	return {
		"grid_size": Vector2i(width, height),
		"player_start": player_start,
		"enemy_starts": enemy_starts,
		"walls": walls,
	}
