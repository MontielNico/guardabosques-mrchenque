extends Control
class_name MainMenu

# Menú Principal del Juego - Guarda-Bosques: Parque Chalet Huergo

@onready var start_btn: Button = get_node_or_null("MenuButtons/StartButton")
@onready var credits_btn: Button = get_node_or_null("MenuButtons/CreditsButton")
@onready var credits_dialog: AcceptDialog = get_node_or_null("CreditsDialog")

func _ready() -> void:
	SoundManager.play_music("ambient", 1.2, -6.0)
	if not start_btn:
		start_btn = find_child("StartButton", true, false) as Button
	if not credits_btn:
		credits_btn = find_child("CreditsButton", true, false) as Button
	if not credits_dialog:
		credits_dialog = find_child("CreditsDialog", true, false) as AcceptDialog

	if start_btn:
		start_btn.pressed.connect(_on_start_pressed)
	if credits_btn:
		credits_btn.pressed.connect(_on_credits_pressed)

func _on_start_pressed() -> void:
	SoundManager.play_sound("click")
	GameManager.play_prologue()

func _on_credits_pressed() -> void:
	SoundManager.play_sound("click")
	if credits_dialog:
		credits_dialog.popup_centered()
