extends PanelContainer
class_name CarInspectionModal

# Modal de Inspección Detallada del Vehículo (Baúl e Interior)

signal closed

@onready var title_label: Label = $MarginContainer/VBoxContainer/Header/TitleLabel
@onready var passengers_label: Label = $MarginContainer/VBoxContainer/Content/VBox/PassengerInfo/PassengersCountLabel
@onready var items_container: VBoxContainer = $MarginContainer/VBoxContainer/Content/VBox/ItemsScroll/ItemsList
@onready var close_button: Button = $MarginContainer/VBoxContainer/Header/CloseButton

var current_visitor_data: Dictionary = {}

func _ready() -> void:
	if close_button:
		close_button.pressed.connect(_on_close_pressed)

func open_inspection(visitor_data: Dictionary) -> void:
	current_visitor_data = visitor_data
	visible = true
	SoundManager.play_sound("paper")
	
	var car_name = visitor_data.get("car_name", "Vehículo")
	var actual_passengers = visitor_data.get("actual_passengers", 1)
	var declared_passengers = visitor_data.get("declared_passengers", 1)
	var items = visitor_data.get("car_items", [])
	
	if title_label:
		title_label.text = "🔍 INSPECCIÓN DE VEHÍCULO: " + car_name.to_upper()
	
	if passengers_label:
		var pass_text = "Pasajeros encontrados a bordo: %d (Declarados en permiso: %d)" % [actual_passengers, declared_passengers]
		if actual_passengers != declared_passengers:
			pass_text += " ⚠️ ¡DISCREPANCIA DETECTADA!"
			passengers_label.modulate = Color(1.0, 0.3, 0.3)
		else:
			pass_text += " ✔️ Coincide con lo declarado"
			passengers_label.modulate = Color(0.8, 1.0, 0.8)
		passengers_label.text = pass_text
		
	# Limpiar y poblar lista de ítems encontrados en baúl
	for child in items_container.get_children():
		child.queue_free()
		
	if items.is_empty():
		var empty_lbl = Label.new()
		empty_lbl.text = "El baúl y los asientos están completamente vacíos."
		empty_lbl.modulate = Color(0.7, 0.7, 0.7)
		items_container.add_child(empty_lbl)
	else:
		for item_name in items:
			var item_panel = PanelContainer.new()
			var item_style = StyleBoxFlat.new()
			item_style.bg_color = Color(0.18, 0.22, 0.26, 0.8)
			item_style.set_corner_radius_all(6)
			item_style.set_content_margin_all(8)
			item_panel.add_theme_stylebox_override("panel", item_style)
			
			var hbox = HBoxContainer.new()
			hbox.add_theme_constant_override("separation", 10)
			
			var icon_lbl = Label.new()
			icon_lbl.text = _get_item_icon(item_name)
			icon_lbl.add_theme_font_size_override("font_size", 20)
			hbox.add_child(icon_lbl)
			
			var name_lbl = Label.new()
			name_lbl.text = item_name
			name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			name_lbl.add_theme_font_size_override("font_size", 14)
			
			# Destacar sospechosos
			if _is_item_suspicious(item_name):
				name_lbl.modulate = Color(1.0, 0.5, 0.3)
			hbox.add_child(name_lbl)
			
			item_panel.add_child(hbox)
			items_container.add_child(item_panel)

func _get_item_icon(item_name: String) -> String:
	var lower = item_name.to_lower()
	if "carbón" in lower or "parrilla" in lower or "leña" in lower or "alcohol" in lower:
		return "🔥"
	elif "caña" in lower or "pesca" in lower or "redes" in lower or "arpón" in lower:
		return "🎣"
	elif "cámara" in lower or "foto" in lower:
		return "📷"
	elif "mate" in lower or "termo" in lower or "sándwich" in lower:
		return "🧉"
	elif "motosierra" in lower or "hacha" in lower:
		return "🪓"
	elif "rifle" in lower or "trampa" in lower or "arma" in lower or "gomera" in lower:
		return "🎯"
	elif "chapas" in lower or "alambre" in lower or "postes" in lower:
		return "🚧"
	elif "perro" in lower:
		return "🐕"
	elif "escondida" in lower:
		return "👤"
	else:
		return "📦"

func _is_item_suspicious(item_name: String) -> bool:
	var lower = item_name.to_lower()
	return "carbón" in lower or "parrilla" in lower or "motosierra" in lower or "hacha" in lower or "rifle" in lower or "trampa" in lower or "redes" in lower or "chapas" in lower or "alambre" in lower or "escondida" in lower or "combustible" in lower

func _on_close_pressed() -> void:
	SoundManager.play_sound("click")
	visible = false
	closed.emit()
