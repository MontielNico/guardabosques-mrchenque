extends PanelContainer
class_name DocumentView

# Visualización e Interacción de los Documentos del Visitante (Ventana 4: Escritorio)
# Muestra DNI, Pase de Visita Diario, Permiso de Actividad, Firmas, Sellos y Anomalías

const FONT_SPECIAL_ELITE: FontFile = preload("res://fonts/SpecialElite-Regular.ttf")

@onready var doc_title: Label = $Margin/VBox/Header/DocTitle
@onready var name_val: Label = $Margin/VBox/Grid/NameVal
@onready var dni_val: Label = $Margin/VBox/Grid/DniVal
@onready var date_val: Label = $Margin/VBox/Grid/DateVal
@onready var purpose_val: Label = $Margin/VBox/Grid/PurposeVal
@onready var people_val: Label = $Margin/VBox/Grid/PeopleVal
@onready var job_permit_val: Label = $Margin/VBox/Grid/JobPermitVal

@onready var fire_permit_val: Label = $Margin/VBox/PermitsBox/FirePermitVal
@onready var fishing_permit_val: Label = $Margin/VBox/PermitsBox/FishingPermitVal
@onready var stamp_visual: Label = $StampVisual

var is_stamped: bool = false

func _configure_stamp_visual() -> void:
	if not stamp_visual:
		return
	stamp_visual.visible = false
	stamp_visual.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stamp_visual.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	stamp_visual.autowrap_mode = TextServer.AUTOWRAP_OFF
	stamp_visual.add_theme_font_override("font", FONT_SPECIAL_ELITE)
	stamp_visual.add_theme_font_size_override("font_size", 28)
	stamp_visual.add_theme_constant_override("line_spacing", -10)
	stamp_visual.add_theme_constant_override("outline_size", 3)
	stamp_visual.add_theme_color_override("font_outline_color", Color(0.18, 0.12, 0.07, 0.85))
	stamp_visual.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.22))
	stamp_visual.add_theme_constant_override("shadow_offset_x", 2)
	stamp_visual.add_theme_constant_override("shadow_offset_y", 2)
	stamp_visual.modulate = Color(1.0, 1.0, 1.0, 0.0)
	stamp_visual.rotation = 0.0
	stamp_visual.scale = Vector2(1.0, 1.0)
	stamp_visual.position = Vector2.ZERO
	stamp_visual.pivot_offset = Vector2.ZERO
	stamp_visual.set_anchors_preset(Control.PRESET_CENTER)
	stamp_visual.offset_left = 0
	stamp_visual.offset_top = 0
	stamp_visual.offset_right = 0
	stamp_visual.offset_bottom = 0

func _ready() -> void:
	_configure_stamp_visual()

func load_document(doc_data: Dictionary) -> void:
	is_stamped = false
	if stamp_visual:
		stamp_visual.visible = false
		stamp_visual.text = ""
		stamp_visual.modulate = Color(1.0, 1.0, 1.0, 0.0)
		stamp_visual.rotation = 0.0
		stamp_visual.scale = Vector2(1.0, 1.0)
		stamp_visual.position = Vector2.ZERO
		stamp_visual.pivot_offset = Vector2.ZERO
	
	var doc_type_str = doc_data.get("type", "Pase de Visita Diario")
	if doc_title:
		doc_title.text = "🏛️ " + doc_type_str.to_upper()
		
	# 1. Nombre / Titular en papeles (DNI vs Pase vs Permiso)
	if name_val:
		var dni_name = doc_data.get("name_on_dni", doc_data.get("name", "Desconocido"))
		var pass_name = doc_data.get("name_on_pass", dni_name)
		var permit_name = doc_data.get("name_on_permit", pass_name)
		
		if dni_name == pass_name and pass_name == permit_name:
			name_val.text = dni_name + " (Coincide en papeles)"
			name_val.modulate = Color(0.1, 0.1, 0.1)
		else:
			# Mostrar discrepancia de nombres
			var disp_text = "DNI: %s" % dni_name
			if pass_name != dni_name:
				disp_text += " | Pase: %s ⚠️" % pass_name
			if permit_name != pass_name and permit_name != dni_name:
				disp_text += " | Permiso: %s ⚠️" % permit_name
			name_val.text = disp_text
			name_val.modulate = Color(0.85, 0.2, 0.1)
			
	# 2. DNI / Documento y Fecha de Vencimiento del DNI
	if dni_val:
		var dni_num = doc_data.get("dni", "00.000.000")
		var is_expired = doc_data.get("is_dni_expired", doc_data.get("is_expired", false))
		var expiry_date = doc_data.get("dni_expiry", "28/11/2026")
		
		if is_expired:
			dni_val.text = "%s (Vto: %s - ⚠️ VENCIDO)" % [dni_num, expiry_date]
			dni_val.modulate = Color(0.9, 0.15, 0.15)
		else:
			dni_val.text = "%s (Vto: %s - Vigente ✔️)" % [dni_num, expiry_date]
			dni_val.modulate = Color(0.1, 0.55, 0.2)
			
	# 3. Fecha de Validez del Pase / Expediente
	if date_val:
		var dt = doc_data.get("date", "28/11/2026")
		var has_illogical_date = doc_data.get("illogical_date", false)
		
		if has_illogical_date:
			date_val.text = "%s (⚠️ FECHA ANÓMALA)" % dt
			date_val.modulate = Color(0.9, 0.15, 0.15)
		else:
			date_val.text = "%s (Jornada Vigente)" % dt
			date_val.modulate = Color(0.15, 0.55, 0.2)
			
	# 4. Motivo / Actividad Autorizada en el Permiso (Para cruzar con diálogo)
	if purpose_val:
		var auth_act = doc_data.get("authorized_activity", doc_data.get("purpose", "Paseo"))
		purpose_val.text = auth_act
		purpose_val.modulate = Color(0.12, 0.35, 0.65)
		
	# 5. Cantidad de Personas
	if people_val:
		var count = doc_data.get("passengers", 1)
		people_val.text = "%d persona%s autorizada%s" % [count, ("s" if count > 1 else ""), ("s" if count > 1 else "")]
		people_val.modulate = Color(0.15, 0.15, 0.15)
		
	# 6. Permiso de Actividad / Oficio / Sello / Firma
	if job_permit_val:
		var job = doc_data.get("job_permit", "Particular")
		var signer = doc_data.get("signed_by", "Administración")
		var stamp_type = doc_data.get("stamp", "Sello Oficial")
		var has_black_seal = doc_data.get("has_black_seal", false)
		var signed_by_silva = doc_data.get("signed_by_silva", false)
		
		var job_text = "%s | %s [%s]" % [job, signer, stamp_type]
		
		if has_black_seal:
			job_text = "⬛ SELLO NEGRO DETECTADO | " + job_text
			job_permit_val.modulate = Color(0.85, 0.1, 0.1)
		elif signed_by_silva:
			job_text = "✍️ FIRMADO POR SILVA | " + job_text
			job_permit_val.modulate = Color(0.85, 0.35, 0.1)
		else:
			job_permit_val.modulate = Color(0.1, 0.4, 0.65)
			
		job_permit_val.text = job_text
		
	# 7. Documentos Anexos / Permisos Especiales (Foto 1920, Mapa Túneles, etc.)
	if fire_permit_val:
		if doc_data.get("has_photo_1920", false):
			fire_permit_val.text = "📷 FOTO 1920: Anexa en escritorio"
			fire_permit_val.modulate = Color(0.7, 0.3, 0.85)
		else:
			var has_fire = doc_data.get("fire_permit", false)
			fire_permit_val.text = "HABILITADO ✔️" if has_fire else "NO AUTORIZADO ❌"
			fire_permit_val.modulate = Color(0.15, 0.65, 0.2) if has_fire else Color(0.7, 0.3, 0.3)
			
	if fishing_permit_val:
		if doc_data.get("has_tunnel_map", false):
			fishing_permit_val.text = "🗺️ MAPA TÚNELES: Anexo manuscrito"
			fishing_permit_val.modulate = Color(0.7, 0.3, 0.85)
		else:
			var has_fishing = doc_data.get("fishing_permit", false)
			fishing_permit_val.text = "HABILITADO ✔️" if has_fishing else "NO AUTORIZADO ❌"
			fishing_permit_val.modulate = Color(0.15, 0.65, 0.2) if has_fishing else Color(0.7, 0.3, 0.3)

func apply_stamp(approved: bool) -> void:
	is_stamped = true
	if stamp_visual:
		stamp_visual.visible = true
		stamp_visual.text = ""
		stamp_visual.rotation = 0.0
		stamp_visual.scale = Vector2.ONE
		stamp_visual.modulate = Color(1.0, 1.0, 1.0, 0.0)
		stamp_visual.position = Vector2.ZERO
		stamp_visual.anchor_left = 0.5
		stamp_visual.anchor_right = 0.5
		stamp_visual.anchor_top = 0.5
		stamp_visual.anchor_bottom = 0.5
		stamp_visual.offset_left = 0
		stamp_visual.offset_top = 0
		stamp_visual.offset_right = 0
		stamp_visual.offset_bottom = 0
		stamp_visual.add_theme_font_size_override("font_size", 28)
		stamp_visual.add_theme_constant_override("outline_size", 4)
		stamp_visual.add_theme_constant_override("line_spacing", -8)

		var stamp_color: Color
		var stamp_text: String
		var end_rotation: float
		if approved:
			stamp_text = "AUTORIZADO\nCHALET HUERGO"
			stamp_color = Color(0.12, 0.72, 0.26, 1.0)
			end_rotation = -0.22
			SoundManager.play_sound("stamp_approve")
		else:
			stamp_text = "DENEGADO\nNO INGRESA"
			stamp_color = Color(0.82, 0.18, 0.18, 1.0)
			end_rotation = 0.25
			SoundManager.play_sound("stamp_reject")

		stamp_visual.text = stamp_text
		stamp_visual.modulate = stamp_color
		stamp_visual.rotation = end_rotation
		stamp_visual.scale = Vector2(0.35, 0.35)
		stamp_visual.position = Vector2(0, -12)

		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(stamp_visual, "scale", Vector2(1.16, 1.16), 0.16).from(Vector2(0.35, 0.35)).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(stamp_visual, "rotation", end_rotation, 0.18).from(end_rotation + 0.55).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(stamp_visual, "modulate:a", 0.96, 0.12)
		tween.tween_property(stamp_visual, "modulate:a", 0.78, 0.2).set_delay(0.8)
		tween.tween_property(stamp_visual, "position", Vector2(0, -8), 0.14).from(Vector2(0, -20)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
