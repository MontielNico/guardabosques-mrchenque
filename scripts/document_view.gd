extends PanelContainer
class_name DocumentView

# Visualización e Interacción del Documento / Pase del Visitante

signal stamped_approved
signal stamped_rejected

@onready var doc_title: Label = $Margin/VBox/Header/DocTitle
@onready var name_val: Label = $Margin/VBox/Grid/NameVal
@onready var dni_val: Label = $Margin/VBox/Grid/DniVal
@onready var date_val: Label = $Margin/VBox/Grid/DateVal
@onready var purpose_val: Label = $Margin/VBox/Grid/PurposeVal
@onready var people_val: Label = $Margin/VBox/Grid/PeopleVal
@onready var fire_permit_val: Label = $Margin/VBox/PermitsBox/FirePermitVal
@onready var fishing_permit_val: Label = $Margin/VBox/PermitsBox/FishingPermitVal
@onready var stamp_visual: Label = $StampVisual

var is_stamped: bool = false

func _ready() -> void:
	if stamp_visual:
		stamp_visual.visible = false

func load_document(doc_data: Dictionary) -> void:
	is_stamped = false
	if stamp_visual:
		stamp_visual.visible = false
	
	if doc_title:
		doc_title.text = doc_data.get("type", "Pase de Ingreso Diario").to_upper()
	if name_val:
		name_val.text = doc_data.get("name", "Desconocido")
	if dni_val:
		dni_val.text = doc_data.get("dni", "00.000.000")
	if date_val:
		var dt = doc_data.get("date", "28/11/2026")
		var expired = doc_data.get("is_expired", false)
		if expired:
			date_val.text = dt + " (⚠️ VENCIDO)"
			date_val.modulate = Color(1.0, 0.3, 0.3)
		else:
			date_val.text = dt + " (Vigente)"
			date_val.modulate = Color(0.8, 1.0, 0.8)
	if purpose_val:
		purpose_val.text = doc_data.get("purpose", "Paseo")
	if people_val:
		people_val.text = str(doc_data.get("passengers", 1)) + " personas"
		
	if fire_permit_val:
		var has_fire = doc_data.get("fire_permit", false)
		fire_permit_val.text = "AUTORIZADO ✔️" if has_fire else "NO AUTORIZADO ❌"
		fire_permit_val.modulate = Color(0.3, 0.9, 0.4) if has_fire else Color(0.9, 0.4, 0.4)
		
	if fishing_permit_val:
		var has_fishing = doc_data.get("fishing_permit", false)
		fishing_permit_val.text = "HABILITADO ✔️" if has_fishing else "NO HABILITADO ❌"
		fishing_permit_val.modulate = Color(0.3, 0.9, 0.4) if has_fishing else Color(0.9, 0.4, 0.4)

func apply_stamp(approved: bool) -> void:
	is_stamped = true
	if stamp_visual:
		stamp_visual.visible = true
		if approved:
			stamp_visual.text = "【 AUTORIZADO 】\nPARQUE CHALET HUERGO"
			stamp_visual.modulate = Color(0.1, 0.8, 0.2, 0.9)
			stamp_visual.rotation = -0.12
			SoundManager.play_sound("stamp_approve")
		else:
			stamp_visual.text = "【 DENEGADO 】\nRECHAZO DE ACCESO"
			stamp_visual.modulate = Color(0.9, 0.15, 0.15, 0.9)
			stamp_visual.rotation = 0.15
			SoundManager.play_sound("stamp_reject")
