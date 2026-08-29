extends Control
class_name PatagoniaView

# Vista Exterior Panorámica desde la Ventana de la Oficina (Ventana 1: Superior Izquierda)

var barrier_angle: float = 0.0 # 0.0 = cerrada, 1.0 = abierta
var car_pos_x: float = 80.0
var car_target_x: float = 80.0
var car_color: Color = Color(0.35, 0.55, 0.75)
var car_type_name: String = "Automóvil"

var cloud_offsets: Array[float] = [0.0, 140.0, 280.0, 420.0]
var wind_particles: Array[Vector2] = []
const NUM_PARTICLES = 16

## NUEVO: hook visual para DayManager.environment_flags_applied (Día 3).
## No sabe nada de "por qué" hay niebla, solo pinta un velo gris si se lo piden.
var is_foggy: bool = false

func _ready() -> void:
	for i in range(NUM_PARTICLES):
		wind_particles.append(Vector2(randf() * 400.0, randf() * 300.0))

func _process(delta: float) -> void:
	var w = maxf(size.x, 300.0)
	
	# Nubes
	for i in range(cloud_offsets.size()):
		cloud_offsets[i] += delta * (20.0 + i * 8.0)
		if cloud_offsets[i] > w + 60.0:
			cloud_offsets[i] = -80.0
	
	# Partículas de viento patagónico
	for i in range(wind_particles.size()):
		wind_particles[i].x += delta * 120.0
		wind_particles[i].y += sin(wind_particles[i].x * 0.03) * delta * 15.0
		if wind_particles[i].x > w + 20.0:
			wind_particles[i].x = -10.0
			wind_particles[i].y = randf() * size.y * 0.8
			
	# Suavizado de auto
	car_pos_x = lerpf(car_pos_x, car_target_x, delta * 5.0)
	queue_redraw()

## NUEVO: llamado desde MainGame al recibir DayManager.environment_flags_applied.
func apply_environment_flags(flags: Dictionary) -> void:
	is_foggy = flags.get("is_foggy", false)
	queue_redraw()

func set_visitor(visitor_data: Dictionary) -> void:
	car_color = visitor_data.get("car_color", Color(0.4, 0.6, 0.8))
	car_type_name = visitor_data.get("car_name", "Vehículo")
	
	# Animación de llegada
	car_pos_x = -240.0
	car_target_x = size.x * 0.22 if size.x > 100 else 80.0
	barrier_angle = 0.0

func open_barrier_and_pass() -> void:
	barrier_angle = 1.0
	car_target_x = size.x + 220.0 # Pasa barrera hacia adentro

func reject_and_turn_back() -> void:
	barrier_angle = 0.0
	car_target_x = -260.0 # Da media vuelta

func _draw() -> void:
	var w = size.x
	var h = size.y
	if w <= 0 or h <= 0:
		return
	
	# 1. Cielo Patagónico
	_draw_sky_gradient(w, h * 0.65)
	
	# 2. Nubes
	_draw_clouds()
	
	# 3. Cerro Chenque
	_draw_mountains(w, h)
	
	# 4. Costa y mar patagónico
	draw_rect(Rect2(0, h * 0.42, w, h * 0.12), Color(0.18, 0.32, 0.45))
	draw_line(Vector2(0, h * 0.44), Vector2(w, h * 0.44), Color(0.7, 0.85, 0.9, 0.35), 1.5)
	
	# 5. Terreno y vegetación
	_draw_terrain(w, h)
	
	# 6. Bosque de Lengas y Pinos
	_draw_forest(w, h)
	
	# 7. Asfalto / Camino del parque
	draw_rect(Rect2(0, h * 0.68, w, h * 0.32), Color(0.24, 0.25, 0.27))
	for i in range(0, int(w), 50):
		draw_rect(Rect2(i, h * 0.82, 28, 4), Color(0.85, 0.75, 0.2, 0.8))
		
	# 8. Auto del visitante
	_draw_car(car_pos_x, h * 0.64)
	
	# 9. Barrera de Control
	_draw_barrier(w * 0.75, h * 0.74, h)
	
	# 10. Partículas de viento
	for p in wind_particles:
		draw_circle(p, 1.5, Color(0.8, 0.7, 0.5, 0.6))
		
	# 11. Marco de Ventana de Madera de la Garita
	_draw_window_frame(w, h)

	# 12. NUEVO: velo de niebla costera (Día 3 - is_foggy)
	if is_foggy:
		draw_rect(Rect2(0, 0, w, h), Color(0.75, 0.78, 0.8, 0.32))

func _draw_sky_gradient(w: float, sky_h: float) -> void:
	var top_color = Color(0.25, 0.48, 0.72)
	var bottom_color = Color(0.68, 0.82, 0.92)
	var steps = 10
	for i in range(steps):
		var y1 = (sky_h / steps) * i
		var y2 = (sky_h / steps) * (i + 1)
		var col = top_color.lerp(bottom_color, float(i) / steps)
		draw_rect(Rect2(0, y1, w, y2 - y1 + 1), col)

func _draw_clouds() -> void:
	for x in cloud_offsets:
		var c_col = Color(1.0, 1.0, 1.0, 0.6)
		draw_circle(Vector2(x, 30), 18, c_col)
		draw_circle(Vector2(x + 20, 26), 24, c_col)
		draw_circle(Vector2(x + 45, 32), 16, c_col)
		draw_rect(Rect2(x - 10, 30, 65, 12), c_col)

func _draw_mountains(w: float, h: float) -> void:
	var mountain_color = Color(0.58, 0.46, 0.38)
	var pts: PackedVector2Array = [
		Vector2(0, h * 0.46),
		Vector2(w * 0.2, h * 0.32),
		Vector2(w * 0.45, h * 0.34),
		Vector2(w * 0.7, h * 0.28),
		Vector2(w * 0.9, h * 0.3),
		Vector2(w, h * 0.42),
		Vector2(w, h * 0.55),
		Vector2(0, h * 0.55)
	]
	draw_colored_polygon(pts, mountain_color)
	draw_line(Vector2(w * 0.2, h * 0.35), Vector2(w * 0.45, h * 0.36), Color(0.72, 0.58, 0.46), 2.5)

func _draw_terrain(w: float, h: float) -> void:
	var grass_color = Color(0.32, 0.45, 0.28)
	var pts: PackedVector2Array = [
		Vector2(0, h * 0.5),
		Vector2(w * 0.3, h * 0.48),
		Vector2(w * 0.7, h * 0.52),
		Vector2(w, h * 0.49),
		Vector2(w, h * 0.7),
		Vector2(0, h * 0.7)
	]
	draw_colored_polygon(pts, grass_color)

func _draw_forest(w: float, h: float) -> void:
	var tree_x_positions = [20, 60, 110, 240, 290, 340]
	for tx in tree_x_positions:
		var base_y = h * 0.52
		var tree_h = 45 + (int(tx) % 15)
		draw_rect(Rect2(tx - 3, base_y - tree_h * 0.4, 6, tree_h * 0.4), Color(0.32, 0.22, 0.15))
		var fol_col = Color(0.2, 0.36, 0.24).lerp(Color(0.26, 0.42, 0.28), float(int(tx) % 4) / 4.0)
		draw_circle(Vector2(tx, base_y - tree_h * 0.7), 16, fol_col)
		draw_circle(Vector2(tx - 8, base_y - tree_h * 0.55), 12, fol_col)
		draw_circle(Vector2(tx + 8, base_y - tree_h * 0.55), 13, fol_col)

func _draw_barrier(bx: float, by: float, h: float) -> void:
	draw_rect(Rect2(bx - 6, by - 30, 12, 50), Color(0.2, 0.2, 0.22))
	draw_circle(Vector2(bx, by - 22), 8, Color(0.85, 0.2, 0.2))
	
	var bar_len = 110.0
	var bar_angle_rad = -barrier_angle * (PI * 0.45)
	var end_x = bx - cos(bar_angle_rad) * bar_len
	var end_y = (by - 22) + sin(bar_angle_rad) * bar_len
	
	draw_line(Vector2(bx, by - 22), Vector2(end_x, end_y), Color(0.9, 0.9, 0.9), 7.0)
	for i in range(4):
		var t1 = 0.15 + i * 0.22
		var t2 = t1 + 0.11
		var p1 = Vector2(bx, by - 22).lerp(Vector2(end_x, end_y), t1)
		var p2 = Vector2(bx, by - 22).lerp(Vector2(end_x, end_y), t2)
		draw_line(p1, p2, Color(0.85, 0.15, 0.15), 7.0)

func _draw_car(cx: float, cy: float) -> void:
	draw_circle(Vector2(cx + 60, cy + 45), 50, Color(0.1, 0.1, 0.1, 0.35))
	
	var car_w = 160.0
	var car_h = 45.0
	
	draw_rect(Rect2(cx, cy + 12, car_w, car_h), car_color)
	
	var roof_pts: PackedVector2Array = [
		Vector2(cx + 28, cy + 12),
		Vector2(cx + 48, cy - 14),
		Vector2(cx + 120, cy - 14),
		Vector2(cx + 142, cy + 12)
	]
	draw_colored_polygon(roof_pts, car_color)
	
	var win_pts: PackedVector2Array = [
		Vector2(cx + 35, cy + 10),
		Vector2(cx + 52, cy - 10),
		Vector2(cx + 115, cy - 10),
		Vector2(cx + 135, cy + 10)
	]
	draw_colored_polygon(win_pts, Color(0.4, 0.6, 0.75, 0.85))
	
	var w1 = Vector2(cx + 32, cy + 56)
	var w2 = Vector2(cx + 128, cy + 56)
	draw_circle(w1, 16, Color(0.15, 0.15, 0.15))
	draw_circle(w1, 8, Color(0.7, 0.7, 0.75))
	draw_circle(w2, 16, Color(0.15, 0.15, 0.15))
	draw_circle(w2, 8, Color(0.7, 0.7, 0.75))
	
	draw_rect(Rect2(cx + car_w - 4, cy + 18, 4, 12), Color(1.0, 0.9, 0.4))
	draw_rect(Rect2(cx, cy + 18, 4, 12), Color(0.85, 0.1, 0.1))

func _draw_window_frame(w: float, h: float) -> void:
	var frame_color = Color(0.24, 0.17, 0.12)
	var border = 6.0
	draw_rect(Rect2(0, 0, w, border), frame_color)
	draw_rect(Rect2(0, h - border, w, border), frame_color)
	draw_rect(Rect2(0, 0, border, h), frame_color)
	draw_rect(Rect2(w - border, 0, border, h), frame_color)
	
	# Cruz de ventana de garita
	draw_line(Vector2(w * 0.5, 0), Vector2(w * 0.5, h), frame_color, 4.0)
	draw_line(Vector2(0, h * 0.45), Vector2(w, h * 0.45), frame_color, 4.0)
