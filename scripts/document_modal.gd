extends PanelContainer
class_name DocumentModal

# Modal interactivo para inspección minuciosa y detallada del documento del visitante
# Muestra DNI, nombres en papeles, fechas, actividad autorizada, sellos, firmas y anomalías

signal closed

const FONT_SPECIAL_ELITE: FontFile = preload("res://fonts/SpecialElite-Regular.ttf")
const FONT_VT323: FontFile = preload("res://fonts/VT323-Regular.ttf")
const FONT_PRESS_START: FontFile = preload("res://fonts/PressStart2P-Regular.ttf")

@onready var agency_header: Label = $Margin/VBox/Header/VBox/AgencyHeader
@onready var doc_title: Label = $Margin/VBox/Header/VBox/DocTitle
@onready var doc_subtitle: Label = $Margin/VBox/Header/VBox/DocSubtitle
@onready var close_btn: Button = $Margin/VBox/Header/CloseButton

@onready var name_val: Label = $Margin/VBox/Content/Scroll/PaperPanel/Margin/VBox/Grid/NameVal
@onready var dni_val: Label = $Margin/VBox/Content/Scroll/PaperPanel/Margin/VBox/Grid/DniVal
@onready var date_val: Label = $Margin/VBox/Content/Scroll/PaperPanel/Margin/VBox/Grid/DateVal
@onready var purpose_val: Label = $Margin/VBox/Content/Scroll/PaperPanel/Margin/VBox/Grid/PurposeVal
@onready var people_val: Label = $Margin/VBox/Content/Scroll/PaperPanel/Margin/VBox/Grid/PeopleVal
@onready var job_permit_val: Label = $Margin/VBox/Content/Scroll/PaperPanel/Margin/VBox/Grid/JobPermitVal

@onready var fire_permit_val: Label = $Margin/VBox/Content/Scroll/PaperPanel/Margin/VBox/PermitsBox/FirePermitVal
@onready var fishing_permit_val: Label = $Margin/VBox/Content/Scroll/PaperPanel/Margin/VBox/PermitsBox/FishingPermitVal
@onready var notes_val: Label = $Margin/VBox/Content/Scroll/PaperPanel/Margin/VBox/NotesVal

@onready var stamp_visual: Label = $Margin/VBox/Content/Scroll/PaperPanel/StampVisual
@onready var bottom_close_btn: Button = $Margin/VBox/Footer/BottomCloseButton

var current_doc_data: Dictionary = {}

func _ready() -> void:
	if close_btn:
		close_btn.pressed.connect(_on_close_pressed)
	if bottom_close_btn:
		bottom_close_btn.pressed.connect(_on_close_pressed)
	_configure_stamp_visual()

func _configure_stamp_visual() -> void:
	if not stamp_visual:
		return
	stamp_visual.visible = false
	stamp_visual.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stamp_visual.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	stamp_visual.add_theme_font_override("font", FONT_SPECIAL_ELITE)
	stamp_visual.add_theme_font_size_override("font_size", 34)
	stamp_visual.add_theme_constant_override("outline_size", 4)
	stamp_visual.add_theme_color_override("font_outline_color", Color(0.1, 0.08, 0.05, 0.95))
	stamp_visual.modulate = Color(1.0, 1.0, 1.0, 0.0)

func open_document(doc_data: Dictionary, visitor_data: Dictionary = {}) -> void:
	current_doc_data = doc_data
	visible = true
	SoundManager.play_sound("paper")
	
	if stamp_visual:
		stamp_visual.visible = false
		stamp_visual.text = ""
		stamp_visual.modulate = Color(1.0, 1.0, 1.0, 0.0)
		
	var doc_type_str = doc_data.get("type", "Pase de Visita Diario")
	if doc_title:
		doc_title.text = "🏛️ " + doc_type_str.to_upper()
	if doc_subtitle:
		var category = doc_data.get("job_permit", visitor_data.get("visitor_type", "Particular"))
		doc_subtitle.text = "EXPEDIENTE OFICIAL DE CONTROL — REGISTRO: %s" % category.to_upper()
		
	# 1. Nombre / Titular en papeles (DNI vs Pase vs Permiso)
	if name_val:
		var dni_name = doc_data.get("name_on_dni", doc_data.get("name", "Desconocido"))
		var pass_name = doc_data.get("name_on_pass", dni_name)
		var permit_name = doc_data.get("name_on_permit", pass_name)
		
		var name_text = "DNI: %s\nPase de Visita: %s" % [dni_name, pass_name]
		if doc_data.has("name_on_permit"):
			name_text += "\nPermiso de Actividad: %s" % permit_name
		name_val.text = name_text
		name_val.modulate = Color(0.08, 0.3, 0.65)
			
	# 2. DNI / Documento y Vencimiento
	if dni_val:
		var dni_num = doc_data.get("dni", "00.000.000")
		var expiry_date = doc_data.get("dni_expiry", "28/11/2026")
		dni_val.text = "%s\nVencimiento: %s" % [dni_num, expiry_date]
		dni_val.modulate = Color(0.08, 0.3, 0.65)
			
	# 3. Fecha de Validez del Documento
	if date_val:
		var dt = doc_data.get("date", "28/11/2026")
		date_val.text = dt
		date_val.modulate = Color(0.08, 0.3, 0.65)
			
	# 4. Actividad Autorizada (Cotejar con el diálogo oral)
	if purpose_val:
		var auth_act = doc_data.get("authorized_activity", doc_data.get("purpose", "Paseo"))
		purpose_val.text = auth_act
		purpose_val.modulate = Color(0.08, 0.3, 0.65)
		
	# 5. Cantidad de Personas
	if people_val:
		var decl = doc_data.get("passengers", 1)
		people_val.text = "%d persona(s) declarada(s)" % decl
		people_val.modulate = Color(0.08, 0.3, 0.65)
			
	# 6. Permiso de Oficio / Firmante / Sello
	if job_permit_val:
		var job = doc_data.get("job_permit", "Particular")
		var signer = doc_data.get("signed_by", "Administración")
		var stamp_type = doc_data.get("stamp", "Sello Oficial Verde")
		var job_text = "• Habilitación: %s\n• Emisor / Firmante: %s\n• Tipo de Sello: %s" % [job, signer, stamp_type]
		job_permit_val.modulate = Color(0.1, 0.35, 0.6)
		job_permit_val.text = job_text
		
	# 7. Permisos de Fuego y Pesca / Anexos Históricos
	if fire_permit_val:
		if doc_data.get("has_photo_1920", false):
			fire_permit_val.text = "📷 FOTOGRAFÍA DE 1920: Anexo en sepia encontrado en las rocas"
			fire_permit_val.modulate = Color(0.65, 0.25, 0.85)
		else:
			var has_fire = doc_data.get("fire_permit", false)
			fire_permit_val.text = "Permiso de fuego: Sí" if has_fire else "Permiso de fuego: No"
			fire_permit_val.modulate = Color(0.1, 0.35, 0.6)
			
	if fishing_permit_val:
		if doc_data.get("has_tunnel_map", false):
			fishing_permit_val.text = "🗺️ MAPA DE TÚNELES: Plano manuscrito de galerías bajo Chalet Huergo"
			fishing_permit_val.modulate = Color(0.65, 0.25, 0.85)
		else:
			var has_fishing = doc_data.get("fishing_permit", false)
			fishing_permit_val.text = "Permiso de pesca: Sí" if has_fishing else "Permiso de pesca: No"
			fishing_permit_val.modulate = Color(0.1, 0.35, 0.6)
			
	if notes_val:
		var notes = "• Presentar este pase ante la autoridad de control en la garita del Parque Nacional Chalet Huergo.\n• Prohibido salir de senderos habilitados o perturbar la fauna en Cerro Chenque y costa marina."
		notes_val.text = notes

func apply_stamp(approved: bool) -> void:
	if not stamp_visual:
		return
	stamp_visual.visible = true
	stamp_visual.text = ""
	
	var stamp_color: Color
	var stamp_text: String
	var end_rotation: float
	
	if approved:
		stamp_text = "AUTORIZADO\nPARQUE CHALET HUERGO"
		stamp_color = Color(0.12, 0.72, 0.26, 1.0)
		end_rotation = -0.15
	else:
		stamp_text = "DENEGADO\nACCESO RECHAZADO"
		stamp_color = Color(0.85, 0.18, 0.18, 1.0)
		end_rotation = 0.18
		
	stamp_visual.text = stamp_text
	stamp_visual.modulate = stamp_color
	stamp_visual.rotation = end_rotation
	stamp_visual.scale = Vector2(0.5, 0.5)
	
	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(stamp_visual, "scale", Vector2(1.15, 1.15), 0.18).from(Vector2(0.5, 0.5)).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(stamp_visual, "rotation", end_rotation, 0.18).from(end_rotation + 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(stamp_visual, "modulate:a", 0.95, 0.12)

func _on_close_pressed() -> void:
	SoundManager.play_sound("click")
	visible = false
	closed.emit()

func _unhandled_input(event: InputEvent) -> void:
	if visible and event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.keycode == KEY_ESCAPE or event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			_on_close_pressed()

