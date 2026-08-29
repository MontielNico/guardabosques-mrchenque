extends Node


## DayManager
## Único punto de contacto entre "quiero arrancar el Día N" y
## "acá está el visitante que hay que atender ahora". No sabe nada de UI:
## todo se comunica por señales para que las Views se suscriban.
##
## Pensado como Autoload (Project Settings > Autoload), igual que GameManager.
## VisitorSpawner NO es autoload: vive como instancia interna acá adentro.
##
## División de responsabilidades sugerida:
##   - GameManager: economía familiar, salud de parcelas, día actual (número).
##   - DayManager:  arma y entrega la cola de visitantes de ESE día.
## MainGame se suscribe a DayManager, resuelve la decisión, y sigue usando
## GameManager.record_decision() / finish_current_day() como hasta ahora.

signal day_prepared(day_config: DayConfig, total_visitors: int)
signal visitor_arrived(visitor: VisitorProfile, index: int, total: int)
signal visitor_left(visitor: VisitorProfile, index: int)
signal day_queue_completed(day_number: int)

# ============================================================
# NUEVO: Hooks de la Matriz Narrativa
# ============================================================
# DayManager sigue sin saber nada de UI: solo avisa. Quien quiera reaccionar
# (day_summary.gd, main_game.gd, un futuro EnvironmentController, etc.) se
# suscribe a estas señales. Los nombres respetan literalmente los que pide
# el diseño (OnLogbookFound, EndGame_SilvaClue, EndGame_FleePost) aunque no
# seteen la convención snake_case habitual de GDScript, a propósito, para
# que sean fácilmente rastreables contra el documento de diseño.

## NUEVO: emitida en start_day() con los flags ambientales del DayConfig
## (is_foggy, high_tide_anomalies, y los que se sumen a futuro).
signal environment_flags_applied(flags: Dictionary)

## NUEVO: Día 1, cierre de turno -> le da al jugador la bitácora de Silva.
signal OnLogbookFound

## NUEVO: Día 3, último visitante ("Trabajador del Ministerio") rechazado
## -> el NPC lanza una amenaza antes de irse.
signal npc_threat_issued(visitor: VisitorProfile)

## NUEVO: evento de texto genérico para momentos tipo "Inquietud y Miedo"
## (Día 3, si el jugador aprobó al Trabajador del Ministerio, se dispara
## al cierre del día). event_key identifica el caso para quien lo escuche.
signal narrative_text_event(event_key: String, text: String)

## NUEVO: Día 5, clímax. Sellar [APROBADO] al "Hombre sin rostro".
signal EndGame_SilvaClue

## NUEVO: Día 5, clímax. Sellar [RECHAZADO] al "Hombre sin rostro".
signal EndGame_FleePost

var spawner: VisitorSpawner
var current_day_config: DayConfig
var visitor_queue: Array[VisitorProfile] = []
var current_index: int = -1

## NUEVO: estado interno para diferir el evento de texto del Día 3 hasta el
## cierre de la jornada (la decisión ocurre a mitad del día, pero el efecto
## narrativo es "al final del día" según el documento de diseño).
var _pending_day3_inquietud: bool = false

func _init() -> void:
	spawner = VisitorSpawner.new()

## Genera la cola completa del día (determinista una vez generada) y
## dispara la llegada del primer visitante.
func start_day(day_config: DayConfig) -> void:
	current_day_config = day_config
	visitor_queue = spawner.generate_queue(day_config)
	current_index = -1
	_pending_day3_inquietud = false # NUEVO: reset por día

	day_prepared.emit(day_config, visitor_queue.size())

	# NUEVO: Inyección determinista de efectos ambientales (Día 3 niebla,
	# Día 4 marea alta anómala). Se dispara ANTES del primer visitante para
	# que la UI ya esté "vestida" cuando arranca la jornada.
	environment_flags_applied.emit(day_config.get_environment_flags())

	_advance()

## Llamar UNA VEZ resuelta la decisión sobre el visitante actual
## (aprobado/rechazado, animaciones incluidas) para pedir el siguiente.
func request_next_visitor() -> void:
	if current_index >= 0 and current_index < visitor_queue.size():
		visitor_left.emit(visitor_queue[current_index], current_index)
	_advance()

func get_current_visitor() -> VisitorProfile:
	if current_index >= 0 and current_index < visitor_queue.size():
		return visitor_queue[current_index]
	return null

func get_progress() -> Dictionary:
	return {"index": current_index, "total": visitor_queue.size()}

func _advance() -> void:
	current_index += 1
	if current_index >= visitor_queue.size():
		day_queue_completed.emit(current_day_config.day_number if current_day_config else -1)
		return

	visitor_arrived.emit(visitor_queue[current_index], current_index, visitor_queue.size())

# ============================================================
# NUEVO: Resolución de la Matriz Narrativa
# ============================================================

## NUEVO: MainGame debe llamar a esto UNA VEZ por visitante, inmediatamente
## después de GameManager.record_decision(), pasándole el mismo VisitorProfile
## y el mismo booleano de aprobación. GameManager sigue encargándose SOLO de
## la economía/parcelas (su responsabilidad original); acá resolvemos
## consecuencias de guion, que es responsabilidad de DayManager según la
## división de responsabilidades documentada arriba.
##
## No hace falta romper la firma vieja de nada: es un método nuevo, opcional
## de llamar, así que si alguna View todavía no lo conecta, el resto del
## juego sigue funcionando exactamente igual que antes.
func report_decision(visitor: VisitorProfile, approved: bool) -> void:
	if visitor == null:
		return

	match visitor.narrative_key:
		"day3_trabajador_ministerio":
			if approved:
				# "al final del día se dispara un evento de texto de
				# Inquietud y Miedo" -> difiero hasta fire_end_of_day_hooks().
				_pending_day3_inquietud = true
			else:
				# "el NPC lanza una amenaza" -> inmediato, no espera al cierre.
				npc_threat_issued.emit(visitor)

		"day5_hombre_sin_rostro":
			if approved:
				EndGame_SilvaClue.emit()
			else:
				EndGame_FleePost.emit()

		_:
			pass # Visitante sin peso narrativo especial: no hay nada que resolver.

## NUEVO: MainGame debe llamar a esto una sola vez, al cerrar la jornada
## (antes o al mismo tiempo que GameManager.finish_current_day()), pasando
## el número de día que se acaba de terminar.
func fire_end_of_day_hooks(day_number: int) -> void:
	if day_number == 1:
		OnLogbookFound.emit()

	if day_number == 3 and _pending_day3_inquietud:
		narrative_text_event.emit(
			"day3_inquietud_y_miedo",
			"Esa noche no podés dejar de pensar en el Trabajador del Ministerio. " +
			"Nadie en la administración del parque reconoce ese nombre. " +
			"Una inquietud helada te recorre la espalda."
		)
		_pending_day3_inquietud = false
