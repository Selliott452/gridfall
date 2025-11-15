extends Node
class_name UnitManager

var units_by_cell: Dictionary = {}

func register_unit(unit: Unit, cell: Vector2i) -> void:
	# Put the unit in this cell and sync its grid position
	units_by_cell[cell] = unit
	unit.grid_position = cell
	
func move_unit(unit: Unit, new_cell: Vector2i) -> void:
	# Remove from old cell if present
	if units_by_cell.has(unit.grid_position):
		units_by_cell.erase(unit.grid_position)
		
	# Add to new cell
	units_by_cell[new_cell] = unit
	unit.grid_position = new_cell
	
func get_unit_at(cell: Vector2i) -> Unit:
	# Look up whatever is register for this cell
	if not units_by_cell.has(cell):
		return null
		
	var unit = units_by_cell[cell]
	
	# If the dictionary is holding a freed node, clean it up and treat as empty
	if unit == null or not is_instance_valid(unit) or not unit.is_inside_tree():
		units_by_cell.erase(cell)
		return null
		
	return unit
	
func remove_unit(unit: Unit) -> void:
	# Remove the unit from whatever cell it's currently in
	var to_erase: Array[Vector2i] = []
	for cell in units_by_cell.keys():
		if units_by_cell[cell] == unit:
			to_erase.append(cell)
			
	for cell in to_erase:
		units_by_cell.erase(cell)
		
func cleanup() -> void:
	# Remove any units that have been freed or are no longer in the tree
	var cells_to_erase: Array[Vector2i] = []
	
	for cell in units_by_cell.keys():
		var unit = units_by_cell[cell]
		if unit == null or not is_instance_valid(unit) or not unit.is_inside_tree():
			cells_to_erase.append(cell)
			
	for cell in cells_to_erase:
		units_by_cell.erase(cell)
