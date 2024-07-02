extends Resource
class_name saveGame

@export var bonusItems : Array[int]
@export var finishedLevels : Array[int]
var unlockedLevels = [1]
@export var time : Array
@export var stars_per_level : Array[int]

var welt1_skins = [1, 21, 19, 22, 20, 18, 17, 12]
var welt3_skins = [3, 7, 5, 9, 6, 4, 2, 8]
var world1_player = welt1_skins[0]
var world3_player = welt3_skins[0]
var selectedSkinText = preload("res://assets/skins/character.png")
var owned_skins = [0]
var collected_stars = 0
var controller = false
var three_stars = []
var two_stars = []
var one_star = []
var equipped_skin = 0

func setSkin(id):
	world1_player = welt1_skins[id]
	world3_player = welt3_skins[id]

func getWorld3Player():
	return world3_player

func getWorld1Player():
	return world1_player

func bonusCollected(id : int):
	if !bonusItems.has(id):
		bonusItems.append(id)
		collected_stars += 1
		print(collected_stars)

func levelFinished(id : int):
	finishedLevels.append(id)

func removeBonus(id : int):
	for n in bonusItems.size():
		if bonusItems[n] == id:
			bonusItems.remove_at(n)

func bonusUnlocked() -> bool:
	for n in [1,2,3,4,5]:
		if !bonusItems.has(n):
			return false
	return true

func gameFinished() -> bool:
	for n in [1,2,3,4,5]:
		if !finishedLevels.has(n):
			return false
	return true
	
func equip_skin(id):
	equipped_skin = id
	world1_player = welt1_skins[id]
	world3_player = welt3_skins[id]


