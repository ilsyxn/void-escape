extends GridContainer

class_name Highscore

@export var sort_by := "score"
@export var name_column := "name"
@export var length := 1000
@export var file_name := "user://highscore.save"
@export var column_names := ["name", "score"]
@export var show_place_numbers := true
@export var max_shown_scores := 11
@export var scores = {
	"res://level/world1/level_1.tscn": {"score": 1.51, "level_id": 1.1},
	"res://level/world1/level_2.tscn": {"score": 4, "level_id": 1.2},
	"res://level/world1/level_3.tscn": {"score": 5.48, "level_id": 1.3},
	"res://level/world1/level_4.tscn": {"score": 4.58, "level_id": 1.4},
	"res://level/world1/level_5.tscn": {"score": 4.73, "level_id": 1.5},
	"res://level/world2/level_2_1.tscn": {"score": 6.08, "level_id": 2.1},
	"res://level/world2/level_2_2.tscn": {"score": 6.62, "level_id": 2.2},
	"res://level/world2/level_2_3.tscn": {"score": 16.72, "level_id": 2.3},
	"res://level/world2/level_2_4.tscn": {"score": 9.6, "level_id": 2.4},
	"res://level/world2/level_2_5.tscn": {"score": 8.55, "level_id": 2.5},
	"res://level/world3/level_3_1.tscn": {"score": 8.75, "level_id": 3.1},
	"res://level/world3/level_3_2.tscn": {"score": 20.85, "level_id": 3.2},
	"res://level/world3/level_3_3.tscn": {"score": 20.38, "level_id": 3.3},
	"res://level/world3/level_3_4.tscn": {"score": 0, "level_id": 3.4},
	"res://level/world3/level_3_5.tscn": {"score": 0, "level_id": 3.5}
}

var highscore := []
var latest_name := ""
var latest_data: Dictionary

func _ready():
	_load()
	_update_highscore()

func get_minimum_score():
	if len(highscore) < length:
		return INF
	return highscore[-1][sort_by]

func add_entry(new_entry: Dictionary) -> int:
	latest_name = new_entry[name_column]
	latest_data = new_entry
	var result = -1
	for i in range(len(highscore)):
		var entry = highscore[i]
		if new_entry[sort_by] < entry[sort_by]:
			highscore.insert(i, new_entry)
			result = i + 1
			break

	if result == -1 and len(highscore) < length:
		highscore.append(new_entry)
		result = len(highscore)

	if len(highscore) > length:
		highscore.pop_back()

	_update_highscore()
	_save()
	return result

func _create_label(text, ratio:=1.0) -> Label:
	var label = Label.new()
	label.text = str(text)
	label.theme_type_variation = "HighscoreLabel"
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.size_flags_stretch_ratio = ratio
	
	var custom_font = load("res://assets/ui/gomarice_mix_bit_font.ttf")
	label.add_theme_font_override("font", custom_font)
	
	return label



func _update_highscore():
	for label in get_children():
		remove_child(label)
		label.queue_free()

	var place = 0
	for entry in highscore:
		place += 1
		if show_place_numbers:
			add_child(_create_label(str(place) + ".", 0.1))
		for col in column_names:
			add_child(_create_label(entry[col]))

func _load():
	if FileAccess.file_exists(file_name):
		var highscore_file = FileAccess.open(file_name, FileAccess.READ)
		var data = JSON.parse_string(highscore_file.get_as_text())
		highscore = data["list"]
		if "latest_name" in data:
			latest_name = data["latest_name"]

func _save():
	var highscore_file = FileAccess.open(file_name, FileAccess.WRITE)
	var json_string = JSON.stringify({"list": highscore, "latest_name": latest_name})
	highscore_file.store_string(json_string)
	highscore_file.close()

func _update_shown_scores(level):
	columns = len(column_names)
	if show_place_numbers:
		columns += 1

	for label in get_children():
		remove_child(label)
		label.queue_free()
		
	add_child(_create_label(" ---- "))
	add_child(_create_label("Leaderboard"))
	add_child(_create_label("----"))

	var place = 0
	var shown_scores = 0
	var latest_data_place = -1

  # Find the place of the latest data considering the level ID
	for i in range(len(highscore)):
		if highscore[i]["level_id"] == level and highscore[i] == latest_data:
			latest_data_place = place + 1
			break
		if highscore[i]["level_id"] == level:
			place += 1

	place = 0
	for entry in highscore:
		if entry["level_id"] == level:
			place += 1
			if shown_scores < max_shown_scores - 1:
				if show_place_numbers:
					add_child(_create_label(str(place) + ".", 0.1))
				for col in column_names:
					add_child(_create_label(entry[col]))
				shown_scores += 1
			elif shown_scores < max_shown_scores:
				shown_scores += 1
				add_child(_create_label("..."))
				add_child(_create_label("..."))
				add_child(_create_label("..."))
				
				if latest_data != {} and latest_data_place > 10:
					add_child(_create_label(str(latest_data_place) + ".", 0.1))
					for col in column_names:
						add_child(_create_label(latest_data[col]))
			else:
				break
	add_child(_create_label(""))
	add_child(_create_label(""))
	add_child(_create_label(""))

