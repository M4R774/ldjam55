extends VBoxContainer

var MANAGER: GAME_MANAGER

var screen_size = Vector2(0, 0)
var speed = 1
var direction = Vector2(1, 1)
var hide_darkness = false
var darkness_alpha = 1.0


func _ready():
	MANAGER = get_node("/root/GAME_MANAGER_SINGLETON")
	for item in MANAGER.ITEMS_TO_BUY:
		var label = Label.new()
		label.text = "Press A to summon " + item["name"]
		label.set("theme_override_font_sizes/font_size", 24)
		add_child(label)
	for fish in MANAGER.FISH_TO_BUY:
		var label = Label.new()
		label.text = "Press S to summon " + fish["name"]
		label.set("theme_override_font_sizes/font_size", 24)
		add_child(label)
	for plant in MANAGER.PLANTS_TO_BUY:
		var label = Label.new()
		label.text = "Press D to summon " + plant["name"]
		label.set("theme_override_font_sizes/font_size", 24)
		add_child(label)

	# Spend all mana and nutrients to buy stuff
	for item in MANAGER.ITEMS_TO_BUY:
		try_buying_autofeeder(item)
	for fish in MANAGER.FISH_TO_BUY:
		try_buying_fish(fish)
	for plant in MANAGER.PLANTS_TO_BUY:
		try_buying_plant(plant)

	update_HUD()
	screen_size = get_viewport_rect().size


func _process(delta):
	update_HUD()

	screen_size = get_viewport_rect().size

	# Bounce off the screen edges
	if position.x >= screen_size.x - size.x:
		direction.x = abs(direction.x)*-1
	if position.y >= screen_size.y - size.y:
		direction.y = abs(direction.y)*-1
	if position.x <= 0:
		direction.x = abs(direction.x)
	if position.y <= 0:
		direction.y = abs(direction.y)
	position += direction * speed * delta

	handle_input()


func handle_input():
	if Input.is_action_just_pressed("summon_fish"):
		handle_buying_fish()
	
	if Input.is_action_just_pressed("summon_plant"):
		handle_buying_plant()

	if Input.is_action_just_pressed("summon_auto_feeder"):
		handle_buying_auto_feeder()


func update_HUD():
	var children = get_children()
	if MANAGER.if_any_fish_is_hungry() and MANAGER.ITEMS_TO_BUY[0]["available"] == true and MANAGER.FOOD.size() <= 0:
		children[0].show()
	else:
		children[0].hide()
	var children_counter = 1

	for item in MANAGER.ITEMS_TO_BUY:
		if item["price"] <= MANAGER.NUTRIENTS and item["available"] == true:
			children[children_counter].show()
		else:
			children[children_counter].hide()
		children_counter = children_counter + 1

	var fish_available = false
	for fish in MANAGER.FISH_TO_BUY:
		if fish["price"] <= MANAGER.MANA and fish["available"] and not fish_available:
			children[children_counter].show()
			fish_available = true
		else:
			children[children_counter].hide()
		children_counter = children_counter + 1

	var plant_available = false
	for plant in MANAGER.PLANTS_TO_BUY:
		if plant["price"] <= MANAGER.NUTRIENTS and plant["available"] and not plant_available:
			children[children_counter].show()
			plant_available = true
		else:
			children[children_counter].hide()
		children_counter = children_counter + 1


func handle_buying_fish():
	for fish in MANAGER.FISH_TO_BUY:
		if fish["available"]:
			try_buying_fish(fish)
			break


func try_buying_fish(fish):
	if fish["price"] <= MANAGER.MANA:
		MANAGER.add_mana(-fish["price"])
		fish["available"] = false
		var new_fish = fish["scene"].instantiate()
		screen_size = get_viewport_rect().size
		get_node("/root/Root").add_child.call_deferred(new_fish)


func handle_buying_plant():
	for plant in MANAGER.PLANTS_TO_BUY:
		if plant["available"]:
			try_buying_plant(plant)
			break


func try_buying_plant(plant):
	if plant["price"] <= MANAGER.NUTRIENTS:
		MANAGER.add_nutrients(-plant["price"])
		plant["available"] = false
		get_node(plant["node_path"]).show()
		if plant.has("hide_panel_path"):
			get_node(plant["hide_panel_path"]).make_hidden()


func handle_buying_auto_feeder():
	for autofeeder in MANAGER.ITEMS_TO_BUY:
		if autofeeder["available"]:
			try_buying_autofeeder(autofeeder)


func try_buying_autofeeder(autofeeder):
	if autofeeder["price"] <= MANAGER.NUTRIENTS:
		MANAGER.add_nutrients(-autofeeder["price"])
		autofeeder["available"] = false


func has_enough_money(price):
	return MANAGER.MONEY >= price
