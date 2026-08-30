extends PanelContainer
class_name ParkMapView

# Componente Visual del Mapa General del Parque Chalet Huergo (5 Parcelas sobre mapa.jpg)

@onready var parcels_vbox: VBoxContainer = $Margin/VBox/Scroll/ParcelsList
@onready var map_canvas: Control = $Margin/VBox/MapCanvas

const MAP_TEXTURE: Texture2D = preload("res://public/mapa.jpg")
const FONT_VT323: FontFile = preload("res://fonts/VT323-Regular.ttf")

# Configuración espacial de las 5 parcelas en la textura de mapa.jpg (1024x1024)
const PARCEL_CONFIG = {
	"Cerro Chenque y Acantilados": {
		"id": 1,
		"label": "Parcela 1",
		"icon": "⛰️",
		"norm_pos": Vector2(0.24, 0.30),
		"short_name": "Cerro Chenque"
	},
	"Costa y Pingüinera": {
		"id": 2,
		"label": "Parcela 2",
		"icon": "🐧",
		"norm_pos": Vector2(0.76, 0.22),
		"short_name": "Costa y Pingüinera"
	},
	"Chalet Histórico": {
		"id": 3,
		"label": "Parcela 3",
		"icon": "🏛️",
		"norm_pos": Vector2(0.58, 0.52),
		"short_name": "Chalet Histórico"
	},
	"Bosque de Lengas": {
		"id": 4,
		"label": "Parcela 4",
		"icon": "🌲",
		"norm_pos": Vector2(0.28, 0.66),
		"short_name": "Bosque de Lengas"
	},
	"Humedal y Laguna de Aves": {
		"id": 5,
		"label": "Parcela 5",
		"icon": "🦆",
		"norm_pos": Vector2(0.80, 0.80),
		"short_name": "Humedal y Laguna"
	}
}

var hovered_parcel: String = ""

func _ready() -> void:
	if map_canvas:
		map_canvas.draw.connect(_on_map_canvas_draw)
		map_canvas.gui_input.connect(_on_map_canvas_gui_input)
		map_canvas.mouse_exited.connect(_on_map_canvas_mouse_exited)
	update_map()

func update_map() -> void:
	if map_canvas:
		map_canvas.queue_redraw()
		
	if not parcels_vbox:
		return
		
	for child in parcels_vbox.get_children():
		child.queue_free()
		
	for p_name in PARCEL_CONFIG:
		var cfg = PARCEL_CONFIG[p_name]
		var health = GameManager.parcels_health.get(p_name, 100.0)
		var tags: Array = GameManager.parcels_damage_tags.get(p_name, [])
		
		var p_panel = PanelContainer.new()
		var p_style = StyleBoxFlat.new()
		p_style.bg_color = Color(0.1, 0.14, 0.18, 0.9)
		p_style.border_color = Color(0.28, 0.38, 0.48, 0.7)
		p_style.set_border_width_all(1)
		p_style.set_corner_radius_all(5)
		p_style.content_margin_left = 6
		p_style.content_margin_right = 6
		p_style.content_margin_top = 4
		p_style.content_margin_bottom = 4
		p_panel.add_theme_stylebox_override("panel", p_style)
		
		var vbox = VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 2)
		
		# Header de parcela (Icono, Parcela X, Nombre y Salud %)
		var header_hbox = HBoxContainer.new()
		header_hbox.add_theme_constant_override("separation", 6)
		
		var icon_lbl = Label.new()
		icon_lbl.text = cfg.get("icon", "📍")
		icon_lbl.add_theme_font_size_override("font_size", 13)
		header_hbox.add_child(icon_lbl)
		
		var name_lbl = Label.new()
		name_lbl.text = "[P%d] %s" % [cfg.get("id", 0), cfg.get("short_name", p_name)]
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_lbl.add_theme_font_size_override("font_size", 11)
		header_hbox.add_child(name_lbl)
		
		var pct_lbl = Label.new()
		pct_lbl.text = "%.0f%%" % health
		pct_lbl.add_theme_font_size_override("font_size", 11)
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
		bar.custom_minimum_size = Vector2(0, 6)
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
					"tala", "tala_irregular": tag_text += "🪓 Árboles Talados  "
					"incendio": tag_text += "🔥 Fuego/Cenizas  "
					"caza": tag_text += "🎯 Animales Cazados  "
					"usurpacion": tag_text += "🏗️ Usurpación/Chapas  "
					"pesca_furtiva": tag_text += "🚫 Pesca Ilegal  "
					"acampe": tag_text += "🏕️ Acampe Indebido  "
					"colapso": tag_text += "💀 Parcela Colapsada  "
					_: tag_text += "⚠️ Parcela Afectada  "
			
			if tag_text.is_empty():
				tag_text = "⚠️ Daño Ecológico Detectado"
				
			tag_lbl.text = tag_text
			tag_lbl.add_theme_font_size_override("font_size", 9)
			tag_lbl.modulate = Color(1.0, 0.4, 0.3)
			tag_hbox.add_child(tag_lbl)
			vbox.add_child(tag_hbox)
			
		p_panel.add_child(vbox)
		parcels_vbox.add_child(p_panel)

func _get_map_rect() -> Rect2:
	if not map_canvas:
		return Rect2()
	var w = map_canvas.size.x
	var h = map_canvas.size.y
	if w <= 0.0 or h <= 0.0:
		return Rect2()
	return Rect2(0, 0, w, h)

func _on_map_canvas_draw() -> void:
	if not map_canvas:
		return
	var w = map_canvas.size.x
	var h = map_canvas.size.y
	if w <= 0.0 or h <= 0.0:
		return
		
	# Fondo oscuro uniforme
	map_canvas.draw_rect(Rect2(0, 0, w, h), Color(0.06, 0.08, 0.1, 1.0))
	
	var map_rect = _get_map_rect()
	if map_rect.size.x <= 0.0:
		return
		
	# Sombra suave bajo el mapa
	map_canvas.draw_rect(map_rect.grow(3), Color(0, 0, 0, 0.5), true)
	
	# Dibujar textura del mapa real
	if MAP_TEXTURE:
		map_canvas.draw_texture_rect(MAP_TEXTURE, map_rect, false)
	else:
		map_canvas.draw_rect(map_rect, Color(0.15, 0.2, 0.25, 1.0))
		
	# Borde estilizado del mapa
	map_canvas.draw_rect(map_rect, Color(0.35, 0.45, 0.55, 0.8), false, 2.0)
	
	# Dibujar marcadores de estado de las 5 parcelas
	for p_name in PARCEL_CONFIG:
		var cfg = PARCEL_CONFIG[p_name]
		var norm_pos: Vector2 = cfg.get("norm_pos", Vector2.ZERO)
		var pos = map_rect.position + norm_pos * map_rect.size
		
		var health = GameManager.parcels_health.get(p_name, 100.0)
		var tags: Array = GameManager.parcels_damage_tags.get(p_name, [])
		var is_hovered = (hovered_parcel == p_name)
		var is_collapsed = (health <= 0.0)
		var is_damaged = (not tags.is_empty() or health < 100.0)
		
		# Determinar color según estado de salud
		var status_color: Color
		if is_collapsed:
			status_color = Color(0.85, 0.15, 0.15)
		elif health >= 75.0:
			status_color = Color(0.25, 0.88, 0.38) # Verde
		elif health >= 40.0:
			status_color = Color(0.96, 0.78, 0.18) # Amarillo
		else:
			status_color = Color(0.95, 0.28, 0.25) # Rojo
			
		var base_radius = 10.0 if is_hovered else 8.0
		
		# Sombra del marcador
		map_canvas.draw_circle(pos + Vector2(1, 1), base_radius + 2.0, Color(0, 0, 0, 0.75))
		
		# Anillo exterior
		var ring_color = Color(1.0, 0.9, 0.3) if is_hovered else Color(1, 1, 1, 0.9)
		var ring_width = 2.5 if is_hovered else 1.5
		map_canvas.draw_arc(pos, base_radius + 1.5, 0, TAU, 16, ring_color, ring_width)
		
		# Relleno del círculo de estado
		map_canvas.draw_circle(pos, base_radius, status_color)
		
		# Centro / Icono de colapso
		if is_collapsed:
			map_canvas.draw_line(pos + Vector2(-3, -3), pos + Vector2(3, 3), Color.BLACK, 2.0)
			map_canvas.draw_line(pos + Vector2(-3, 3), pos + Vector2(3, -3), Color.BLACK, 2.0)
		else:
			map_canvas.draw_circle(pos, 2.0, Color.WHITE)
			
		# Pastilla con el porcentaje de salud (% exacto)
		var pct_text = "%.0f%%" % health
		var badge_w = 26.0
		var badge_h = 11.0
		var badge_pos = Vector2(pos.x - badge_w * 0.5, pos.y + base_radius + 2.0)
		var badge_rect = Rect2(badge_pos, Vector2(badge_w, badge_h))
		
		# Fondo de pastilla
		map_canvas.draw_rect(badge_rect, Color(0.08, 0.1, 0.12, 0.92), true)
		map_canvas.draw_rect(badge_rect, status_color, false, 1.0)
		
		if FONT_VT323:
			map_canvas.draw_string(FONT_VT323, Vector2(badge_pos.x, badge_pos.y + 9.0), pct_text, HORIZONTAL_ALIGNMENT_CENTER, badge_w, 11, Color.WHITE)
			
		# Alerta de daño visual
		if is_damaged:
			var alert_pos = pos + Vector2(base_radius * 0.7, -base_radius * 0.7)
			map_canvas.draw_circle(alert_pos, 4.0, Color(1.0, 0.25, 0.2))
			map_canvas.draw_circle(alert_pos, 2.0, Color(1.0, 0.95, 0.3))
			
	# Tooltip al posar el cursor sobre una parcela
	if hovered_parcel != "" and PARCEL_CONFIG.has(hovered_parcel):
		var cfg = PARCEL_CONFIG[hovered_parcel]
		var h_val = GameManager.parcels_health.get(hovered_parcel, 100.0)
		var h_tags = GameManager.parcels_damage_tags.get(hovered_parcel, [])
		
		var tip_w = map_rect.size.x - 12.0
		var tip_h = 24.0
		var tip_x = map_rect.position.x + 6.0
		# Si la parcela está en la parte inferior, colocar tooltip arriba; si está arriba, colocarlo abajo
		var tip_y = map_rect.position.y + 6.0 if cfg["norm_pos"].y > 0.5 else map_rect.position.y + map_rect.size.y - tip_h - 6.0
		var tip_rect = Rect2(tip_x, tip_y, tip_w, tip_h)
		
		map_canvas.draw_rect(tip_rect, Color(0.08, 0.12, 0.16, 0.95), true)
		map_canvas.draw_rect(tip_rect, Color(1.0, 0.85, 0.4, 0.9), false, 1.5)
		
		var tip_title = "%s %s: %s (%.0f%%)" % [cfg.get("icon", "📍"), cfg.get("label", ""), cfg.get("short_name", hovered_parcel), h_val]
		var tip_col = Color(0.3, 0.9, 0.4) if h_val >= 75.0 else (Color(0.95, 0.8, 0.2) if h_val >= 40.0 else Color(0.95, 0.3, 0.3))
		
		if FONT_VT323:
			map_canvas.draw_string(FONT_VT323, Vector2(tip_x + 4, tip_y + 16), tip_title, HORIZONTAL_ALIGNMENT_LEFT, tip_w - 8, 14, tip_col)

func _on_map_canvas_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var map_rect = _get_map_rect()
		if map_rect.size.x <= 0.0:
			return
			
		var mouse_pos = event.position
		var newly_hovered = ""
		
		for p_name in PARCEL_CONFIG:
			var cfg = PARCEL_CONFIG[p_name]
			var norm_pos: Vector2 = cfg.get("norm_pos", Vector2.ZERO)
			var pos = map_rect.position + norm_pos * map_rect.size
			if mouse_pos.distance_to(pos) <= 16.0:
				newly_hovered = p_name
				break
				
		if newly_hovered != hovered_parcel:
			hovered_parcel = newly_hovered
			if map_canvas:
				map_canvas.queue_redraw()

func _on_map_canvas_mouse_exited() -> void:
	if hovered_parcel != "":
		hovered_parcel = ""
		if map_canvas:
			map_canvas.queue_redraw()
