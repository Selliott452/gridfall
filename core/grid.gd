extends Node2D
class_name Grid

@export var grid_size: Vector2i = Vector2i(10,8)
@export var tile_size: Vector2 = Vector2(64,64)

@export var top_ui_height: float = 40.0
@export var bottom_ui_height: float = 80.0

var grid_origin: Vector2 = Vector2.ZERO
var selected_cell: Vector2i = Vector2i(-1,-1)

var highlighted_cells: Array[Vector2i] = []
var highlighted_color: Color = Color(0, 0, 0, 0)

var wall_cells: Array[Vector2i] = []

func _ready() -> void:
	_compute_grid_origin()
	queue_redraw()

func rebuild() -> void:
	_compute_grid_origin()
	queue_redraw()
	
func _compute_grid_origin() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var grid_pixel_size := Vector2(
		float(grid_size.x) * tile_size.x,
		float(grid_size.y) * tile_size.y
	)
	
	var available_height := viewport_size.y - top_ui_height - bottom_ui_height
	
	grid_origin = Vector2(
		(viewport_size.x - grid_pixel_size.x) / 2.0,
		top_ui_height + (available_height - grid_pixel_size.y) / 2.0
	)

func cell_to_world(cell: Vector2i) -> Vector2:
	return grid_origin + Vector2(
		float(cell.x) * tile_size.x,
		float(cell.y) * tile_size.y
	)
	
func world_to_cell(pos: Vector2) -> Vector2i:
	var local := pos - grid_origin
	return Vector2i(
		int(floor(local.x / tile_size.x)),
		int(floor(local.y / tile_size.y))
	)
	
func is_in_bounds(cell: Vector2i) -> bool:
	return (
		cell.x >= 0 and
		cell.y >= 0 and 
		cell.x < grid_size.x and 
		cell.y < grid_size.y
	)

func set_walls(cells: Array[Vector2i]) -> void:
	wall_cells = cells.duplicate()
	queue_redraw()
	
func is_wall(cell: Vector2i) -> bool:
	return wall_cells.has(cell)

func set_selected_cell(cell: Vector2i) -> void:
	selected_cell = cell
	queue_redraw()
	
func set_highlight_cells(cells: Array[Vector2i], color: Color) -> void:
	highlighted_cells = cells.duplicate()
	highlighted_color = color
	queue_redraw()

func clear_highlight_cells() -> void:
	highlighted_cells.clear()
	queue_redraw()
	
func _draw() -> void:
	# Draw grid tiles
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var cell := Vector2i(x,y)
			var top_left := cell_to_world(cell)
			var rect := Rect2(top_left, tile_size)
			
			var base_color := Color(0.9,0.9,0.9,1.0)
			if is_wall(cell):
				base_color = Color(0.2, 0.2, 0.2, 1.0)
			
			#fill
			draw_rect(rect, base_color, true)
			#border
			draw_rect(rect, Color(0.7,0.7,0.7,1.0), false)
	
	# Highlight all valid target cells
	for cell in highlighted_cells:
		if is_in_bounds(cell) and not is_wall(cell):
			var top_left := cell_to_world(cell)
			var rect := Rect2(top_left, tile_size)
			draw_rect(rect, highlighted_color, true)
	
	if is_in_bounds(selected_cell) and not is_wall(selected_cell):
		var top_left := cell_to_world(selected_cell)
		var highlight_rect := Rect2(top_left, tile_size)
		
		draw_rect(highlight_rect, Color(1.0,1.0,0.0,0.3), true)
		draw_rect(highlight_rect, Color(1.0,1.0,0.0,0.9), false)
