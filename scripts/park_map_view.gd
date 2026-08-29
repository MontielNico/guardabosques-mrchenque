extends PanelContainer
class_name ParkMapView

# Componente Visual del Mapa General del Parque Chalet Huergo (5 Parcelas)

@onready var parcels_vbox: VBoxContainer = $Margin/VBox/Scroll/ParcelsList
@onready var map_canvas: Control = $Margin/VBox/MapCanvas

const PARCEL_ICONS = {
	"Chalet Histórico": "🏛️",
	"Bosque de Lengas": "🌲",
	"Costa y Pingüinera": "🐧",
	"Cerro Chenque y Acantilados": "⛰️",
	"Humedal y Laguna de Aves": "🦆"
}

func _ready() -> void:
	if map_canvas:
		map_canvas.draw.connect(_on_map_canvas_draw)
	update_map()

func update_map() -> void:
	if map_canvas:
		map_canvas.queue_redraw()
		
	if not parcels_vbox:
		return
		
	for child in parcels_vbox.get_children():
		child.queue_free()
		
	for p_name in GameManager.parcels_health:
		var health = GameManager.parcels_health[p_name]
		var tags: Array = GameManager.parcels_damage_tags.get(p_name, [])
		
		var p_panel = PanelContainer.new()
		var p_style = StyleBoxFlat.new()
		p_style.bg_color = Color(0.12, 0.16, 0.2, 0.85)
		p_style.set_corner_radius_all(6)
		p_style.set_content_margin_all(6)
		p_panel.add_theme_stylebox_override("panel", p_style)
		
		var vbox = VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 2)
		
		# Header de parcela (Icono, Nombre y Salud %)
		var header_hbox = HBoxContainer.new()
		header_hbox.add_theme_constant_override("separation", 6)
		
		var icon_lbl = Label.new()
		icon_lbl.text = PARCEL_ICONS.get(p_name, "📍")
		icon_lbl.add_theme_font_size_override("font_size", 14)
		header_hbox.add_child(icon_lbl)
		
		var name_lbl = Label.new()
		name_lbl.text = p_name
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_lbl.add_theme_font_size_override("font_size", 12)
		header_hbox.add_child(name_lbl)
		
		var pct_lbl = Label.new()
		pct_lbl.text = "%.0f%%" % health
		pct_lbl.add_theme_font_size_override("font_size", 12)
		if health >= 75.0:
			pct_lbl.modulate = Color(0.3, 0.9, 0.4)
		elif health >= 40.0:
			pct_lbl.modulate = Color(0.95, 0.8, 0.2)
		else:
			pct_lbl.modulate = Color(0.95, 0.25, 0.25)
		header_hbox.add_child(pct_lbl)
		
		vbox.add_child(header_hbox)
		
		# Barra de progreso
		var bar = ProgressBar.new()
		bar.max_value = 100.0
		bar.value = health
		bar.show_percentage = false
		bar.custom_minimum_size = Vector2(0, 8)
		if health >= 75.0:
			bar.modulate = Color(0.3, 0.9, 0.4)
		elif health >= 40.0:
			bar.modulate = Color(0.95, 0.8, 0.2)
		else:
			bar.modulate = Color(0.95, 0.25, 0.25)
		vbox.add_child(bar)
		
		# Indicadores de Daño Visual / Anomalías
		if not tags.is_empty() or health < 100.0:
			var tag_hbox = HBoxContainer.new()
			tag_hbox.add_theme_constant_override("separation", 4)
			
			var tag_lbl = Label.new()
			var tag_text = ""
			for t in tags:
				match t:
					"tala": tag_text += "🪓 Árboles Talados  "
					"incendio": tag_text += "🔥 Fuego/Cenizas  "
					"caza": tag_text += "🎯 Animales Cazados  "
					"usurpacion": tag_text += "🏗️ Usurpación/Chapas  "
					"pesca_furtiva": tag_text += "🚫 Pesca Ilegal  "
					"acampe": tag_text += "🏕️ Acampe Indebido  "
					_: tag_text += "⚠️ Parcela Afectada  "
			
			if tag_text.is_empty():
				tag_text = "⚠️ Daño Ecológico Detectado"
				
			tag_lbl.text = tag_text
			tag_lbl.add_theme_font_size_override("font_size", 10)
			tag_lbl.modulate = Color(1.0, 0.4, 0.3)
			tag_hbox.add_child(tag_lbl)
			vbox.add_child(tag_hbox)
			
		p_panel.add_child(vbox)
		parcels_vbox.add_child(p_panel)

func _on_map_canvas_draw() -> void:
	if not map_canvas:
		return
	var w = map_canvas.size.x
	var h = map_canvas.size.y
	if w <= 0 or h <= 0:
		return
		
	# Fondo de mapa topográfico patagónico
	map_canvas.draw_rect(Rect2(0, 0, w, h), Color(0.1, 0.14, 0.18, 0.95))
	
	# Costa y Mar Atlántico
	var coast_pts: PackedVector2Array = [
		Vector2(w * 0.7, 0),
		Vector2(w, 0),
		Vector2(w, h),
		Vector2(w * 0.55, h),
		Vector2(w * 0.65, h * 0.5)
	]
	map_canvas.draw_colored_polygon(coast_pts, Color(0.15, 0.28, 0.38, 0.7))
	
	# Rutas / Senderos internos
	map_canvas.draw_line(Vector2(w * 0.1, h * 0.5), Vector2(w * 0.45, h * 0.45), Color(0.65, 0.55, 0.4, 0.8), 2.0)
	map_canvas.draw_line(Vector2(w * 0.45, h * 0.45), Vector2(w * 0.7, h * 0.3), Color(0.65, 0.55, 0.4, 0.8), 2.0)
	map_canvas.draw_line(Vector2(w * 0.45, h * 0.45), Vector2(w * 0.5, h * 0.8), Color(0.65, 0.55, 0.4, 0.8), 2.0)
	map_canvas.draw_line(Vector2(w * 0.45, h * 0.45), Vector2(w * 0.25, h * 0.2), Color(0.65, 0.55, 0.4, 0.8), 2.0)
	
	# Dibujar marcadores de las 5 parcelas en el mapa
	var parcel_coords = {
		"Chalet Histórico": Vector2(w * 0.45, h * 0.45),
		"Bosque de Lengas": Vector2(w * 0.25, h * 0.25),
		"Costa y Pingüinera": Vector2(w * 0.8, h * 0.35),
		"Cerro Chenque y Acantilados": Vector2(w * 0.2, h * 0.75),
		"Humedal y Laguna de Aves": Vector2(w * 0.6, h * 0.78)
	}
	
	for p_name in parcel_coords:
		var pos = parcel_coords[p_name]
		var health = GameManager.parcels_health.get(p_name, 100.0)
		var p_color = Color(0.25, 0.85, 0.35) if health >= 75.0 else (Color(0.95, 0.8, 0.2) if health >= 40.0 else Color(0.95, 0.2, 0.2))
		
		# Círculo base de parcela
		map_canvas.draw_circle(pos, 10, p_color)
		map_canvas.draw_arc(pos, 13, 0, TAU, 16, Color.WHITE, 1.5)
		
		# Si tiene daño visual, dibujar alerta en mapa
		var tags: Array = GameManager.parcels_damage_tags.get(p_name, [])
		if not tags.is_empty():
			# Destello de alerta
			map_canvas.draw_circle(Vector2(pos.x + 8, pos.y - 8), 5, Color(1.0, 0.2, 0.2))
			map_canvas.draw_line(Vector2(pos.x - 6, pos.y - 6), Vector2(pos.x + 6, pos.y + 6), Color.BLACK, 2.0)
			map_canvas.draw_line(Vector2(pos.x - 6, pos.y + 6), Vector2(pos.x + 6, pos.y - 6), Color.BLACK, 2.0)
