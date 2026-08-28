extends Control
class_name PatagoniaView

# Vista Exterior Panorámica del Puesto de Control en Chalet Huergo

var barrier_angle: float = 0.0 # 0.0 = cerrada (horizontal), 1.0 = abierta (vertical)
var car_pos_x: float = 200.0 # Posición horizontal del auto
var car_target_x: float = 200.0
var car_color: Color = Color(0.35, 0.55, 0.75)
var car_type_name: String = "Automóvil"

var visitor_name: String = ""
var visitor_avatar_seed: int = 1
var visitor_expression: String = "neutral" # neutral, nervous, angry, happy

var cloud_offsets: Array[float] = [0.0, 300.0, 700.0, 1050.0]
var wind_particles: Array[Vector2] = []
const NUM_PARTICLES = 25

func _ready() -> void:
	for i in range(NUM_PARTICLES):
		wind_particles.append(Vector2(randf() * 1280.0, randf() * 320.0))

func _process(delta: float) -> void:
	# Mover nubes por el viento patagónico
	for i in range(cloud_offsets.size()):
		cloud_offsets[i] += delta * (40.0 + i * 15.0)
		if cloud_offsets[i] > 1400.0:
			cloud_offsets[i] = -200.0
	
	# Mover partículas de viento / hojas
	for i in range(wind_particles.size()):
		wind_particles[i].x += delta * 180.0
		wind_particles[i].y += sin(wind_particles[i].x * 0.02) * delta * 20.0
		if wind_particles[i].x > 1300.0:
			wind_particles[i].x = -20.0
			wind_particles[i].y = randf() * 320.0
			
	# Suavizado de movimiento de auto y barrera
	car_pos_x = lerpf(car_pos_x, car_target_x, delta * 6.0)
	queue_redraw()

func set_visitor(visitor_data: Dictionary) -> void:
	visitor_name = visitor_data.get("name", "")
	visitor_avatar_seed = visitor_data.get("avatar_seed", 1)
	car_color = visitor_data.get("car_color", Color(0.4, 0.6, 0.8))
	car_type_name = visitor_data.get("car_name", "Vehículo")
	visitor_expression = "neutral"
	
	# Animación de entrada de auto
	car_pos_x = -350.0
	car_target_x = 220.0
	barrier_angle = 0.0

func open_barrier_and_pass() -> void:
	barrier_angle = 1.0
	car_target_x = 1350.0 # Auto avanza hacia adentro del parque
	visitor_expression = "happy"

func reject_and_turn_back() -> void:
	barrier_angle = 0.0
	car_target_x = -400.0 # Auto da media vuelta
	visitor_expression = "angry"

func _draw() -> void:
	var w = size.x
	var h = size.y
	
	# 1. Cielo Patagónico (de azul atlántico a celeste frío)
	_draw_sky_gradient(w, h * 0.7)
	
	# 2. Nubes en movimiento
	_draw_clouds()
	
	# 3. Cerro Chenque y mesetas al fondo (tonos arcilla / ocre patagónico)
	_draw_mountains(w, h)
	
	# 4. Mar frío Atlántico al horizonte
	draw_rect(Rect2(0, h * 0.42, w, h * 0.12), Color(0.18, 0.32, 0.45))
	# Espuma de olas
	draw_line(Vector2(0, h * 0.44), Vector2(w, h * 0.44), Color(0.7, 0.85, 0.9, 0.4), 2.0)
	
	# 5. Colinas costeras y terreno de Chalet Huergo (verde oliva y tierra)
	_draw_terrain(w, h)
	
	# 6. Bosque Patagónico (Lengas, coihues, pinos)
	_draw_forest(w, h)
	
	# 7. Asfalto / Camino de entrada al parque
	draw_rect(Rect2(0, h * 0.72, w, h * 0.28), Color(0.24, 0.25, 0.27))
	# Líneas de camino amarillas
	for i in range(0, int(w), 80):
		draw_rect(Rect2(i, h * 0.85, 45, 6), Color(0.85, 0.75, 0.2, 0.8))
	
	# 8. Caseta del Guardaparques / Chalet Huergo Checkpoint
	_draw_checkpoint_booth(w, h)
	
	# 9. Auto del Visitante
	_draw_car(car_pos_x, h * 0.65)
	
	# 10. Barrera de Control
	_draw_barrier(w * 0.58, h * 0.75, h)
	
	# 11. Partículas de viento / Hojas patagónicas
	for p in wind_particles:
		draw_circle(p, 2.0, Color(0.8, 0.65, 0.4, 0.6))

func _draw_sky_gradient(w: float, sky_h: float) -> void:
	var top_color = Color(0.25, 0.48, 0.72)
	var bottom_color = Color(0.68, 0.82, 0.92)
	var steps = 16
	for i in range(steps):
		var y1 = (sky_h / steps) * i
		var y2 = (sky_h / steps) * (i + 1)
		var t = float(i) / steps
		var col = top_color.lerp(bottom_color, t)
		draw_rect(Rect2(0, y1, w, y2 - y1 + 1), col)

func _draw_clouds() -> void:
	for x in cloud_offsets:
		var c_col = Color(1.0, 1.0, 1.0, 0.65)
		draw_circle(Vector2(x, 45), 28, c_col)
		draw_circle(Vector2(x + 30, 40), 38, c_col)
		draw_circle(Vector2(x + 70, 48), 26, c_col)
		draw_circle(Vector2(x - 25, 50), 22, c_col)
		draw_rect(Rect2(x - 30, 45, 115, 20), c_col)

func _draw_mountains(w: float, h: float) -> void:
	# Meseta patagónica / Cerro Chenque
	var mountain_color = Color(0.58, 0.46, 0.38)
	var pts: PackedVector2Array = [
		Vector2(0, h * 0.48),
		Vector2(w * 0.15, h * 0.32),
		Vector2(w * 0.35, h * 0.33),
		Vector2(w * 0.5, h * 0.38),
		Vector2(w * 0.75, h * 0.28),
		Vector2(w * 0.9, h * 0.29),
		Vector2(w, h * 0.42),
		Vector2(w, h * 0.6),
		Vector2(0, h * 0.6)
	]
	draw_colored_polygon(pts, mountain_color)
	
	# Estratos de arcilla característicos del Cerro Chenque
	draw_line(Vector2(w * 0.15, h * 0.35), Vector2(w * 0.35, h * 0.36), Color(0.72, 0.58, 0.46), 4.0)
	draw_line(Vector2(w * 0.75, h * 0.31), Vector2(w * 0.9, h * 0.32), Color(0.72, 0.58, 0.46), 4.0)

func _draw_terrain(w: float, h: float) -> void:
	var grass_color = Color(0.32, 0.45, 0.28) # Verde lenga/estepa
	var pts: PackedVector2Array = [
		Vector2(0, h * 0.52),
		Vector2(w * 0.25, h * 0.50),
		Vector2(w * 0.6, h * 0.54),
		Vector2(w, h * 0.51),
		Vector2(w, h * 0.75),
		Vector2(0, h * 0.75)
	]
	draw_colored_polygon(pts, grass_color)

func _draw_forest(w: float, h: float) -> void:
	# Árboles patagónicos (Lengas y Coihues de copa densa y pinos)
	var tree_x_positions = [40, 95, 160, 240, 780, 840, 920, 1010, 1120, 1200]
	for tx in tree_x_positions:
		var base_y = h * 0.55
		var tree_h = 75 + (int(tx) % 25)
		# Tronco
		draw_rect(Rect2(tx - 4, base_y - tree_h * 0.4, 8, tree_h * 0.4), Color(0.32, 0.22, 0.15))
		# Copa de árbol
		var foliage_color = Color(0.2, 0.36, 0.24).lerp(Color(0.26, 0.42, 0.28), float(int(tx) % 5) / 5.0)
		draw_circle(Vector2(tx, base_y - tree_h * 0.7), 26, foliage_color)
		draw_circle(Vector2(tx - 12, base_y - tree_h * 0.55), 20, foliage_color)
		draw_circle(Vector2(tx + 12, base_y - tree_h * 0.55), 22, foliage_color)

func _draw_checkpoint_booth(w: float, h: float) -> void:
	# Garita de control estilo madera y piedra patagónica
	var bx = w * 0.65
	var by = h * 0.45
	var bw = 240
	var bh = h * 0.4
	
	# Base de piedra
	draw_rect(Rect2(bx, by + bh * 0.6, bw, bh * 0.4), Color(0.38, 0.38, 0.36))
	# Paredes de madera
	draw_rect(Rect2(bx, by + bh * 0.2, bw, bh * 0.4), Color(0.48, 0.32, 0.2))
	# Tablas de madera horizontales
	for j in range(4):
		draw_line(Vector2(bx, by + bh * 0.2 + j * 16), Vector2(bx + bw, by + bh * 0.2 + j * 16), Color(0.38, 0.25, 0.15), 2.0)
	# Techo a dos aguas verde bosque
	var roof_pts: PackedVector2Array = [
		Vector2(bx - 15, by + bh * 0.2),
		Vector2(bx + bw * 0.5, by - 15),
		Vector2(bx + bw + 15, by + bh * 0.2)
	]
	draw_colored_polygon(roof_pts, Color(0.18, 0.3, 0.22))
	
	# Cartel oficial "PARQUE CHALET HUERGO"
	draw_rect(Rect2(bx + 15, by + bh * 0.05, bw - 30, 24), Color(0.12, 0.24, 0.16))
	var font = get_theme_default_font()
	if font:
		draw_string(font, Vector2(bx + 24, by + bh * 0.05 + 16), "PARQUE CHALET HUERGO", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.95, 0.85, 0.4))
	
	# Ventana de atención de Mr. Chenque
	draw_rect(Rect2(bx + 20, by + bh * 0.25, 90, 60), Color(0.15, 0.2, 0.25))
	draw_rect(Rect2(bx + 22, by + bh * 0.27, 86, 56), Color(0.5, 0.7, 0.85, 0.6)) # Vidrio reflejo

func _draw_barrier(bx: float, by: float, h: float) -> void:
	# Soporte de la barrera
	draw_rect(Rect2(bx - 10, by - 40, 20, 65), Color(0.2, 0.2, 0.22))
	draw_circle(Vector2(bx, by - 30), 12, Color(0.85, 0.2, 0.2))
	
	# Brazo de la barrera (rayas rojas y blancas)
	var bar_len = 170.0
	var bar_angle_rad = -barrier_angle * (PI * 0.45) # Gira hacia arriba
	
	var end_x = bx - cos(bar_angle_rad) * bar_len
	var end_y = (by - 30) + sin(bar_angle_rad) * bar_len
	
	# Dibujar barra
	draw_line(Vector2(bx, by - 30), Vector2(end_x, end_y), Color(0.9, 0.9, 0.9), 10.0)
	# Franjas rojas reflectivas
	for i in range(5):
		var t1 = 0.15 + i * 0.18
		var t2 = t1 + 0.09
		var p1 = Vector2(bx, by - 30).lerp(Vector2(end_x, end_y), t1)
		var p2 = Vector2(bx, by - 30).lerp(Vector2(end_x, end_y), t2)
		draw_line(p1, p2, Color(0.85, 0.15, 0.15), 10.0)

func _draw_car(cx: float, cy: float) -> void:
	# Sombra del auto
	draw_circle(Vector2(cx + 80, cy + 68), 75, Color(0.1, 0.1, 0.1, 0.4))
	
	# Chasis del auto
	var car_w = 230.0
	var car_h = 65.0
	
	# Carrocería principal
	draw_rect(Rect2(cx, cy + 20, car_w, car_h), car_color)
	# Cabina / Techo
	var roof_pts: PackedVector2Array = [
		Vector2(cx + 40, cy + 20),
		Vector2(cx + 70, cy - 18),
		Vector2(cx + 175, cy - 18),
		Vector2(cx + 205, cy + 20)
	]
	draw_colored_polygon(roof_pts, car_color)
	
	# Ventanillas (vidrios)
	var win_pts: PackedVector2Array = [
		Vector2(cx + 50, cy + 18),
		Vector2(cx + 75, cy - 14),
		Vector2(cx + 168, cy - 14),
		Vector2(cx + 195, cy + 18)
	]
	draw_colored_polygon(win_pts, Color(0.4, 0.6, 0.75, 0.85))
	
	# Divisor de ventanillas
	draw_line(Vector2(cx + 120, cy - 14), Vector2(cx + 120, cy + 18), car_color.darkened(0.3), 4.0)
	
	# Ruedas (Neumático y llanta)
	var w1 = Vector2(cx + 45, cy + 85)
	var w2 = Vector2(cx + 185, cy + 85)
	draw_circle(w1, 24, Color(0.15, 0.15, 0.15))
	draw_circle(w1, 12, Color(0.7, 0.7, 0.75))
	draw_circle(w2, 24, Color(0.15, 0.15, 0.15))
	draw_circle(w2, 12, Color(0.7, 0.7, 0.75))
	
	# Luces delanteras y traseras
	draw_rect(Rect2(cx + car_w - 6, cy + 28, 6, 16), Color(1.0, 0.9, 0.4)) # Faro delantero
	draw_rect(Rect2(cx, cy + 28, 6, 16), Color(0.85, 0.1, 0.1)) # Luz trasera roja
	
	# Personaje del Visitante asomado en la ventanilla del conductor
	_draw_visitor_avatar(cx + 85, cy + 6)

func _draw_visitor_avatar(vx: float, vy: float) -> void:
	# Cabeza / Rostro
	var skin_tone = Color(0.92, 0.76, 0.62)
	draw_circle(Vector2(vx, vy), 14, skin_tone)
	
	# Cabello o Gorra según semilla
	if visitor_avatar_seed % 2 == 0:
		# Gorra / Boina patagónica
		draw_arc(Vector2(vx, vy - 4), 16, PI, 2 * PI, 16, Color(0.3, 0.25, 0.2), 6.0)
		draw_line(Vector2(vx - 14, vy - 4), Vector2(vx + 16, vy - 6), Color(0.3, 0.25, 0.2), 4.0)
	else:
		# Cabello
		draw_arc(Vector2(vx, vy - 2), 15, PI * 0.8, PI * 2.2, 16, Color(0.2, 0.15, 0.1), 5.0)
	
	# Ojos
	draw_circle(Vector2(vx + 3, vy - 2), 2.5, Color(0.1, 0.1, 0.1))
	
	# Lentes si la semilla es múltiplo de 3
	if visitor_avatar_seed % 3 == 0:
		draw_rect(Rect2(vx - 2, vy - 5, 10, 6), Color(0.2, 0.2, 0.2), false, 2.0)
	
	# Expresión de boca
	match visitor_expression:
		"happy":
			draw_arc(Vector2(vx + 4, vy + 4), 5, 0.2, PI - 0.2, 8, Color(0.6, 0.1, 0.1), 2.0)
		"angry":
			draw_arc(Vector2(vx + 4, vy + 7), 5, PI + 0.2, 2 * PI - 0.2, 8, Color(0.6, 0.1, 0.1), 2.0)
			# Ceja enojada
			draw_line(Vector2(vx - 1, vy - 7), Vector2(vx + 8, vy - 4), Color(0.2, 0.1, 0.1), 2.0)
		"nervous":
			# Boca ondulada
			draw_line(Vector2(vx + 1, vy + 5), Vector2(vx + 7, vy + 3), Color(0.5, 0.1, 0.1), 2.0)
			# Gota de sudor
			draw_circle(Vector2(vx - 8, vy - 4), 3, Color(0.4, 0.7, 1.0))
		_:
			# Boca neutral
			draw_line(Vector2(vx + 2, vy + 5), Vector2(vx + 7, vy + 5), Color(0.5, 0.1, 0.1), 2.0)
