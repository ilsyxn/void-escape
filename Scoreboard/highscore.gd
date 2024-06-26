extends GridContainer

class_name Highscore

@export var sort_by := "score"
@export var name_column := "name"
@export var length := 10
@export var file_name := "user://highscore.save"
@export var column_names := ["name", "score"]
@export var show_place_numbers := true

var highscore := []
var latest_name := ""

# Called when the node enters the scene tree for the first time.
func _ready():
	_load()


func get_minimum_score():
	if len(highscore) < length:
		return 0
	return highscore[-1][sort_by]

func add_entry(new_entry: Dictionary) -> int:
	latest_name = new_entry[name_column] 
	
	# Case 1: Highscore is empty
	if len(highscore) == 0:
		highscore.append(new_entry)
		_save()
		_update_highscore()
		return 1
		
	var result = -1
	# Case 2: We improved on an existing place
	for i in range(len(highscore)):
		var entry = highscore[i]
		if new_entry[sort_by] > entry[sort_by]:
			highscore.insert(i, new_entry)
			result = i + 1
			break
			
	# Case 3: We did not improve but there is still room
	if result == -1 and len(highscore) < length:
		highscore.append(new_entry)
		result = len(highscore)
	
	_update_highscore()	
	_save()
	return result # Place from 1 to length, -1 if not placed

func _create_label(text, ratio:=1.0) -> Label:
	var label = Label.new()
	label.text = str(text)
	label.theme_type_variation = "HighscoreLabel"
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.size_flags_stretch_ratio = ratio
	return label
	
func _update_highscore():
	# Shorten if necessary
	if len(highscore)>length:
		for i in range(len(highscore) - 1, length - 1, -1):
			highscore.remove_at(i)
			
	columns = len(column_names)
	if show_place_numbers:
		columns += 1
	for label in get_children():
		remove_child(label)
		label.queue_free()
	var place = 0
	for entry in highscore:
		place += 1
		if show_place_numbers:
			add_child(_create_label(str(place, "."), 0.1))
		for col in column_names:
			add_child(_create_label(entry[col]))

func _load():
	if FileAccess.file_exists(file_name):
		var highscore_file = FileAccess.open(file_name, FileAccess.READ)
		var data = JSON.parse_string(highscore_file.get_line())
		highscore = data["list"]
		if "latest_name" in data:
			latest_name = data["latest_name"]
		_update_highscore()

		

func _save():
	var highscore_file = FileAccess.open(file_name, FileAccess.WRITE)
	var json_string = JSON.stringify({"list": highscore, "latest_name": latest_name})
	highscore_file.store_line(json_string)
