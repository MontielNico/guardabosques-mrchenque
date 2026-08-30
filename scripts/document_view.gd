extends PanelContainer
class_name DocumentView

# Componente Visual del Escritorio de Mr. Chenque (Ventana 4: Inferior Izquierda)
# Muestra la superficie de madera de la mesa (wood_table.png) y encima la vista previa del documento (documento.png).
# Al hacer clic en el documento, emite la señal 'document_clicked' para desplegar el modal de detalle completo.

signal document_clicked(doc_data: Dictionary)

const FONT_SPECIAL_ELITE: FontFile = preload("res://fonts/SpecialElite-Regular.ttf")
const FONT_VT323: FontFile = preload("res://fonts/VT323-Regular.ttf")
const FONT_PRESS_START: FontFile = preload("res://fonts/PressStart2P-Regular.ttf")

@onready var table_bg: TextureRect = $TableBackground
@onready var doc_container: Control = $DeskMargin/DeskVBox/DocCenterContainer/DocPreviewCard
@onready var doc_preview_texture: TextureRect = $DeskMargin/DeskVBox/DocCenterContainer/DocPreviewCard/DocTexture
@onready var doc_type_label: Label = $DeskMargin/DeskVBox/DocCenterContainer/DocPreviewCard/DocInfoOverlay/DocTypeLabel
@onready var doc_owner_label: Label = $DeskMargin/DeskVBox/DocCenterContainer/DocPreviewCard/DocInfoOverlay/DocOwnerLabel
@onready var inspect_badge: PanelContainer = $DeskMargin/DeskVBox/DocCenterContainer/DocPreviewCard/InspectBadge
@onready var open_button: Button = $DeskMargin/DeskVBox/DocCenterContainer/DocPreviewCard/OpenDocButton
@onready var desk_title: Label = $DeskMargin/DeskVBox/DeskHeader/DeskTitle
@onready var stamp_visual: Label = $DeskMargin/DeskVBox/DocCenterContainer/DocPreviewCard/StampVisual

var current_doc_data: Dictionary = {}
var is_stamped: bool = false
var is_hovered: bool = false

func _ready() -> void:
	_load_textures()
	_setup_interaction()
	_configure_stamp_visual()

func _load_textures() -> void:
	# Cargar wood_table.png
	var table_tex = _get_texture_safe("res://public/wood_table.png")
	if table_tex and table_bg:
		table_bg.texture = table_tex
		
	# Cargar documento.png
	var doc_tex = _get_texture_safe("res://public/documento.png")
	if doc_tex and doc_preview_texture:
		doc_preview_texture.texture = doc_tex

func _get_texture_safe(res_path: String) -> Texture2D:
	if ResourceLoader.exists(res_path):
		var res = load(res_path)
		if res is Texture2D:
			return res
	if FileAccess.file_exists(res_path):
		var img = Image.load_from_file(ProjectSettings.globalize_path(res_path))
		if img:
			return ImageTexture.create_from_image(img)
	return null

func _setup_interaction() -> void:
	if open_button:
		open_button.pressed.connect(_on_document_clicked)
		open_button.mouse_entered.connect(_on_mouse_entered)
		open_button.mouse_exited.connect(_on_mouse_exited)

func _configure_stamp_visual() -> void:
	if not stamp_visual:
		return
	stamp_visual.visible = false
	stamp_visual.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stamp_visual.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	stamp_visual.add_theme_font_override("font", FONT_SPECIAL_ELITE)
	stamp_visual.add_theme_font_size_override("font_size", 22)
	stamp_visual.add_theme_constant_override("outline_size", 3)
	stamp_visual.add_theme_color_override("font_outline_color", Color(0.1, 0.08, 0.05, 0.9))
	stamp_visual.modulate = Color(1.0, 1.0, 1.0, 0.0)

func load_document(doc_data: Dictionary, visitor_data: Dictionary = {}) -> void:
	current_doc_data = doc_data
	is_stamped = false
	
	if stamp_visual:
		stamp_visual.visible = false
		stamp_visual.text = ""
		stamp_visual.modulate = Color(1.0, 1.0, 1.0, 0.0)
		stamp_visual.rotation = 0.0
		stamp_visual.scale = Vector2.ONE
		
	var doc_type = doc_data.get("type", "Pase de Visita Diario")
	var owner_name = doc_data.get("name_on_dni", doc_data.get("name", visitor_data.get("name", "Visitante")))
	
	if doc_type_label:
		doc_type_label.text = "🏛️ " + doc_type.to_upper()
	if doc_owner_label:
		doc_owner_label.text = "Titular: " + owner_name
		
	if desk_title:
		desk_title.text = "ESCRITORIO DE MR. CHENQUE — PAPELES SOBRE LA MESA"
		
	# Animación de llegada de documento a la mesa
	if doc_container:
		doc_container.modulate = Color(1.0, 1.0, 1.0, 0.0)
		doc_container.position.y = 15.0
		var tw = create_tween()
		tw.set_parallel(true)
		tw.tween_property(doc_container, "modulate:a", 1.0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(doc_container, "position:y", 0.0, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_mouse_entered() -> void:
	is_hovered = true
	if doc_container:
		var tw = create_tween()
		tw.tween_property(doc_container, "scale", Vector2(1.03, 1.03), 0.12).set_trans(Tween.TRANS_QUAD)
	if inspect_badge:
		inspect_badge.modulate = Color(1.0, 0.95, 0.5)

func _on_mouse_exited() -> void:
	is_hovered = false
	if doc_container:
		var tw = create_tween()
		tw.tween_property(doc_container, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_QUAD)
	if inspect_badge:
		inspect_badge.modulate = Color(1.0, 1.0, 1.0)

func _on_document_clicked() -> void:
	SoundManager.play_sound("paper")
	document_clicked.emit(current_doc_data)

func apply_stamp(approved: bool) -> void:
	is_stamped = true
	if not stamp_visual:
		return
		
	stamp_visual.visible = true
	stamp_visual.text = ""
	
	var stamp_color: Color
	var stamp_text: String
	var end_rotation: float
	
	if approved:
		stamp_text = "AUTORIZADO\nCHALET HUERGO"
		stamp_color = Color(0.12, 0.75, 0.28, 1.0)
		end_rotation = -0.18
		SoundManager.play_sound("stamp_approve")
	else:
		stamp_text = "DENEGADO\nNO INGRESA"
		stamp_color = Color(0.85, 0.18, 0.18, 1.0)
		end_rotation = 0.20
		SoundManager.play_sound("stamp_reject")
		
	stamp_visual.text = stamp_text
	stamp_visual.modulate = stamp_color
	stamp_visual.rotation = end_rotation
	stamp_visual.scale = Vector2(0.4, 0.4)
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(stamp_visual, "scale", Vector2(1.1, 1.1), 0.15).from(Vector2(0.4, 0.4)).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(stamp_visual, "rotation", end_rotation, 0.16).from(end_rotation + 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(stamp_visual, "modulate:a", 0.95, 0.1)

