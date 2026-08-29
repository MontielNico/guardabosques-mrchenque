extends Control
class_name MainGame

# Controlador Principal del Puesto de Control en Chalet Huergo (5 Ventanas - Vista 1 y Vista 2)

const PatagoniaView = preload("res://scripts/patagonia_view.gd")
const DocumentView = preload("res://scripts/document_view.gd")
const ParkMapView = preload("res://scripts/park_map_view.gd")
const CarTrunkView = preload("res://scripts/car_trunk_view.gd")
const RulebookModal = preload("res://scripts/rulebook_modal.gd")
const DataDB = preload("res://scripts/data_db.gd")

# Top HUD
@onready var day_badge: Label = $VBox/TopHUD/DayBadge
@onready var visitor_counter_lbl: Label = $VBox/TopHUD/VisitorCounter
@onready var funds_badge: Label = $VBox/TopHUD/FundsBadge
@onready var view_mode_badge: Label = $VBox/TopHUD/ViewModeBadge

# 1° Ventana Superior Izquierda: Oficina y Auto
@onready var patagonia_view: PatagoniaView = $VBox/MainLayout/TopRow/Window1_Office/VBox/PatagoniaView

# 2° Ventana Superior Centro: Visitante, Cara (/public), Diálogo e Interrogatorio
@onready var visitor_avatar_rect: TextureRect = $VBox/MainLayout/TopRow/Window2_Visitor/Margin/VBox/ProfileHBox/AvatarContainer/AvatarTexture
@onready var visitor_name_lbl: Label = $VBox/MainLayout/TopRow/Window2_Visitor/Margin/VBox/ProfileHBox/InfoVBox/VisitorName
@onready var visitor_car_lbl: Label = $VBox/MainLayout/TopRow/Window2_Visitor/Margin/VBox/ProfileHBox/InfoVBox/VisitorCar
@onready var dialog_text: Label = $VBox/MainLayout/TopRow/Window2_Visitor/Margin/VBox/DialogScroll/DialogText
@onready var interrogate_btn: Button = $VBox/MainLayout/TopRow/Window2_Visitor/Margin/VBox/InterrogateBtn

# 3° Ventana Superior Derecha: Mapa del Parque (Vista 1) o Baúl del Auto (Vista 2)
@onready var park_map_view: ParkMapView = $VBox/MainLayout/TopRow/Window3_MapAndTrunk/ParkMapView
@onready var car_trunk_view: CarTrunkView = $VBox/MainLayout/TopRow/Window3_MapAndTrunk/CarTrunkView

# 4° Ventana Inferior Izquierda: Escritorio y Documentos
@onready var document_view: DocumentView = $VBox/MainLayout/BottomRow/Window4_Desk/Margin/VBox/DocumentView

# 5° Ventana Inferior Derecha: Decisiones y Reglamento
@onready var approve_btn: Button = $VBox/MainLayout/BottomRow/Window5_Decisions/Margin/VBox/DecisionsBox/ApproveBtn
@onready var reject_btn: Button = $VBox/MainLayout/BottomRow/Window5_Decisions/Margin/VBox/DecisionsBox/RejectBtn
@onready var inspect_btn: Button = $VBox/MainLayout/BottomRow/Window5_Decisions/Margin/VBox/DecisionsBox/InspectBtn
@onready var back_to_map_btn: Button = $VBox/MainLayout/BottomRow/Window5_Decisions/Margin/VBox/DecisionsBox/BackToMapBtn
@onready var rulebook_btn: Button = $VBox/MainLayout/BottomRow/Window5_Decisions/Margin/VBox/RulebookBtn
@onready var feedback_lbl: Label = $VBox/MainLayout/BottomRow/Window5_Decisions/Margin/VBox/FeedbackLabel
@onready var fire_badge_mini: Label = $VBox/MainLayout/BottomRow/Window5_Decisions/Margin/VBox/InfoMini/FireBadgeMini

# Modales
@onready var rulebook_modal: RulebookModal = $Modals/RulebookModal

var day_info: Dictionary = {}
var visitors_today: Array[Dictionary] = []
var current_visitor_idx: int = 0
var current_visitor: Dictionary = {}
var is_processing_decision: bool = false
var is_in_investigation_mode: bool = false

func _ready() -> void:
	# Conexión de botones
	if approve_btn:
		approve_btn.pressed.connect(_on_approve_pressed)
	if reject_btn:
		reject_btn.pressed.connect(_on_reject_pressed)
	if inspect_btn:
		inspect_btn.pressed.connect(_on_inspect_pressed)
	if back_to_map_btn:
		back_to_map_btn.pressed.connect(_on_back_to_map_pressed)
	if rulebook_btn:
		rulebook_btn.pressed.connect(_on_rulebook_pressed)
	if interrogate_btn:
		interrogate_btn.pressed.connect(_on_interrogate_pressed)
		
	start_day(GameManager.current_day)

func start_day(day_num: int) -> void:
	day_info = DataDB.get_day_info(day_num)
	visitors_today = DataDB.get_visitors_for_day(day_num)
	current_visitor_idx = 0
	is_processing_decision = false
	
	if day_badge:
		day_badge.text = "📅 DÍA %d / %d: %s" % [day_num, GameManager.MAX_DAYS, day_info.get("season", "").to_upper()]
	if funds_badge:
		funds_badge.text = "💵 FONDO FAMILIAR: $%d" % int(GameManager.family_savings)
	if fire_badge_mini:
		var risk = day_info.get("fire_risk", "MEDIO")
		fire_badge_mini.text = "🔥 RIESGO FUEGO: " + risk
		fire_badge_mini.modulate = day_info.get("fire_risk_color", Color.YELLOW)
		
	_set_investigation_mode(false)
	_load_visitor(current_visitor_idx)

func _load_visitor(idx: int) -> void:
	if idx >= visitors_today.size():
		_end_day()
		return
		
	current_visitor = visitors_today[idx]
	is_processing_decision = false
	_set_investigation_mode(false)
	
	if visitor_counter_lbl:
		visitor_counter_lbl.text = "🚗 VEHÍCULO %d DE %d" % [idx + 1, visitors_today.size()]
	if feedback_lbl:
		feedback_lbl.text = ""
		
	# 1. Ventana 1: Auto y exterior
	if patagonia_view:
		patagonia_view.set_visitor(current_visitor)
	SoundManager.play_sound("car_engine")
	
	# 2. Ventana 2: Avatar del visitante desde /public, diálogo y datos
	_load_visitor_avatar(current_visitor.get("avatar_file", ""))
	if visitor_name_lbl:
		visitor_name_lbl.text = current_visitor.get("name", "Visitante")
	if visitor_car_lbl:
		visitor_car_lbl.text = "🚗 " + current_visitor.get("car_name", "Vehículo")
	if dialog_text:
		dialog_text.text = '"' + current_visitor.get("dialog_intro", "Buenas tardes oficial.") + '"'
		dialog_text.modulate = Color(0.92, 0.94, 0.96)
		
	# 3. Ventana 3: Actualizar datos de baúl y mapa
	if park_map_view:
		park_map_view.update_map()
	if car_trunk_view:
		car_trunk_view.set_visitor(current_visitor)
		
	# 4. Ventana 4: Cargar documentos en escritorio
	if document_view:
		var doc_data = current_visitor.get("doc", {})
		document_view.load_document(doc_data)
		
	_enable_decision_buttons(true)

func _load_visitor_avatar(avatar_filename: String) -> void:
	if not visitor_avatar_rect or avatar_filename.is_empty():
		return
		
	var possible_paths = [
		"res://public/" + avatar_filename,
		"res://public/" + avatar_filename.replace("Leña", "Lena").replace("leña", "lena"),
		"res://public/" + avatar_filename.replace("Lena", "Leña").replace("lena", "leña")
	]
	
	var loaded_tex: Texture2D = null
	for p in possible_paths:
		if ResourceLoader.exists(p):
			var res = load(p)
			if res is Texture2D:
				loaded_tex = res
				break
		if FileAccess.file_exists(p):
			var img = Image.load_from_file(p)
			if img:
				loaded_tex = ImageTexture.create_from_image(img)
				break
				
	if loaded_tex:
		visitor_avatar_rect.texture = loaded_tex
	else:
		push_warning("No se pudo cargar la imagen de avatar: " + avatar_filename)

func _set_investigation_mode(enabled: bool) -> void:
	is_in_investigation_mode = enabled
	
	# Ventana 2: Botón de interrogar visible solo en investigación
	if interrogate_btn:
		interrogate_btn.visible = enabled
		if enabled:
			interrogate_btn.modulate = Color(1.0, 0.9, 0.4)
			
	# Ventana 3: Alternar entre Mapa (Vista 1) y Baúl (Vista 2)
	if park_map_view:
		park_map_view.visible = not enabled
		if not enabled:
			park_map_view.update_map()
	if car_trunk_view:
		car_trunk_view.visible = enabled
		if enabled:
			car_trunk_view.set_visitor(current_visitor)
			
	# Ventana 5: Botones
	if inspect_btn:
		inspect_btn.visible = not enabled
	if back_to_map_btn:
		back_to_map_btn.visible = enabled
		
	if view_mode_badge:
		if enabled:
			view_mode_badge.text = "🔍 VISTA 2: INVESTIGACIÓN EN CURSO"
			view_mode_badge.modulate = Color(1.0, 0.75, 0.3)
		else:
			view_mode_badge.text = "📋 VISTA 1: CONTROL PRINCIPAL"
			view_mode_badge.modulate = Color(0.6, 0.9, 1.0)

func _on_inspect_pressed() -> void:
	SoundManager.play_sound("paper")
	_set_investigation_mode(true)

func _on_back_to_map_pressed() -> void:
	SoundManager.play_sound("click")
	_set_investigation_mode(false)

func _on_interrogate_pressed() -> void:
	SoundManager.play_sound("paper")
	if dialog_text and not current_visitor.is_empty():
		var inter_dialog = current_visitor.get("dialog_interrogate", "No tengo nada que ocultar oficial.")
		dialog_text.text = '💬 "' + inter_dialog + '"'
		dialog_text.modulate = Color(1.0, 0.95, 0.7)

func _on_approve_pressed() -> void:
	if is_processing_decision:
		return
	_make_decision(true)

func _on_reject_pressed() -> void:
	if is_processing_decision:
		return
	_make_decision(false)

func _make_decision(approved: bool) -> void:
	is_processing_decision = true
	_enable_decision_buttons(false)
	
	if document_view:
		document_view.apply_stamp(approved)
		
	var decision_result = GameManager.record_decision(current_visitor, approved)
	
	if funds_badge:
		funds_badge.text = "💵 FONDO FAMILIAR: $%d" % int(GameManager.family_savings)
		
	if approved:
		if patagonia_view:
			patagonia_view.open_barrier_and_pass()
		if dialog_text:
			dialog_text.text = '"Muchas gracias oficial Chenque, que tenga buena jornada."'
			dialog_text.modulate = Color(0.7, 1.0, 0.7)
	else:
		if patagonia_view:
			patagonia_view.reject_and_turn_back()
		if dialog_text:
			dialog_text.text = '"¡Qué barbaridad! Me voy a quejar formalmente..."'
			dialog_text.modulate = Color(1.0, 0.6, 0.6)
			
	if feedback_lbl:
		if decision_result.get("status") == "CORRECTO":
			feedback_lbl.text = "✔ DECISIÓN CORRECTA (+Bonus)"
			feedback_lbl.modulate = Color(0.25, 0.95, 0.35)
		else:
			feedback_lbl.text = "✖ ERROR EN REVISIÓN (Multa aplicada)"
			feedback_lbl.modulate = Color(0.95, 0.25, 0.25)
			
	# Actualizar mapa por si hubo impacto ecológico
	if park_map_view:
		park_map_view.update_map()

	# Esperar 2.2 segundos antes del siguiente auto
	await get_tree().create_timer(2.2).timeout
	current_visitor_idx += 1
	_load_visitor(current_visitor_idx)

func _enable_decision_buttons(enabled: bool) -> void:
	if approve_btn:
		approve_btn.disabled = not enabled
	if reject_btn:
		reject_btn.disabled = not enabled
	if inspect_btn:
		inspect_btn.disabled = not enabled
	if back_to_map_btn:
		back_to_map_btn.disabled = not enabled

func _on_rulebook_pressed() -> void:
	if rulebook_modal:
		rulebook_modal.open_rulebook(day_info)

func _end_day() -> void:
	var summary = GameManager.finish_current_day()
	get_tree().change_scene_to_file("res://scenes/day_summary.tscn")
