extends PanelContainer
class_name CarTrunkView

# Componente Visual del Baúl Abierto e Interior del Auto (Vista 2: Investigación)

@onready var trunk_title: Label = $Margin/VBox/TrunkHeader/TitleLabel
@onready var passengers_label: Label = $Margin/VBox/PassengerBox/PassengersCountLabel
@onready var items_container: VBoxContainer = $Margin/VBox/ItemsScroll/ItemsList

func set_visitor(visitor_data: Dictionary) -> void:
	var car_name = visitor_data.get("car_name", "Vehículo")
	var actual_passengers = visitor_data.get("actual_passengers", 1)
	var declared_passengers = visitor_data.get("declared_passengers", 1)
	var items = visitor_data.get("car_items", [])
	
	if trunk_title:
		trunk_title.text = "📦 BAÚL ABIERTO: " + car_name.to_upper()
		
	if passengers_label:
		var pass_text = "👥 Pasajeros reales a bordo: %d  |  Declarados en pase: %d" % [actual_passengers, declared_passengers]
		if actual_passengers != declared_passengers:
			pass_text += "\n⚠️ ¡DISCREPANCIA GRAVE DE PASAJEROS!"
			passengers_label.modulate = Color(1.0, 0.35, 0.35)
		else:
			pass_text += "\n✔️ Coincide con lo declarado en la documentación"
			passengers_label.modulate = Color(0.65, 0.95, 0.65)
		passengers_label.text = pass_text
		
	# Poblar lista de ítems en el baúl
	if items_container:
		for child in items_container.get_children():
			child.queue_free()
			
		if items.is_empty():
			var empty_lbl = Label.new()
			empty_lbl.text = "El baúl y los asientos se encuentran totalmente vacíos."
			empty_lbl.modulate = Color(0.7, 0.7, 0.7)
			empty_lbl.add_theme_font_size_override("font_size", 12)
			items_container.add_child(empty_lbl)
		else:
			for item_name in items:
				var item_panel = PanelContainer.new()
				var item_style = StyleBoxFlat.new()
				item_style.bg_color = Color(0.12, 0.16, 0.2, 0.9)
				item_style.set_corner_radius_all(6)
				item_style.set_content_margin_all(6)
				item_panel.add_theme_stylebox_override("panel", item_style)
				
				var hbox = HBoxContainer.new()
				hbox.add_theme_constant_override("separation", 8)
				
				var icon_lbl = Label.new()
				icon_lbl.text = _get_item_icon(item_name)
				icon_lbl.add_theme_font_size_override("font_size", 16)
				hbox.add_child(icon_lbl)
				
				var name_lbl = Label.new()
				name_lbl.text = item_name
				name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				name_lbl.add_theme_font_size_override("font_size", 12)
				
				if _is_item_suspicious(item_name):
					name_lbl.modulate = Color(1.0, 0.55, 0.3)
					
					var badge = Label.new()
					badge.text = "⚠️ SOSPECHOSO"
					badge.add_theme_font_size_override("font_size", 10)
					badge.modulate = Color(1.0, 0.3, 0.3)
					hbox.add_child(badge)
					
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
	elif "mate" in lower or "termo" in lower or "sándwich" in lower or "vianda" in lower:
		return "🧉"
	elif "motosierra" in lower or "hacha" in lower:
		return "🪓"
	elif "rifle" in lower or "trampa" in lower or "arma" in lower or "gomera" in lower or "jaula" in lower:
		return "🎯"
	elif "chapas" in lower or "alambre" in lower or "postes" in lower:
		return "🏗️"
	elif "perro" in lower:
		return "🐕"
	elif "carpa" in lower or "dormir" in lower:
		return "🏕️"
	elif "escondid" in lower:
		return "👤"
	elif "herramientas" in lower or "ganzúa" in lower:
		return "🔧"
	elif "binocular" in lower:
		return "🔭"
	else:
		return "📦"

func _is_item_suspicious(item_name: String) -> bool:
	var lower = item_name.to_lower()
	return "carbón" in lower or "parrilla" in lower or "motosierra" in lower or "hacha" in lower or "rifle" in lower or "trampa" in lower or "redes" in lower or "arpón" in lower or "chapas" in lower or "alambre" in lower or "postes" in lower or "escondid" in lower or "combustible" in lower or "carpa" in lower or "jaula" in lower or "ganzúa" in lower
