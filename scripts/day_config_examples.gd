extends RefCounted
class_name DayConfigExamples

## DayConfigExamples
## NO es parte del sistema — es un ejemplo de armado por código para que quede
## claro cómo se usa la estructura. En la práctica, para una jam conviene armar
## los VisitorProfile / DocumentData / DayConfig como archivos .tres desde el
## Inspector de Godot (más rápido para el diseñador que tocar código).
##
## MODIFICADO: ahora cubre los 5 días de la Matriz Narrativa completa:
##   Día 1 -> tutorial, solo Simple (sin cambios de contenido).
##   Día 2 -> NUEVO: inyección obligatoria del "Pescador Raro".
##   Día 3 -> MODIFICADO: se agrega is_foggy + inyección obligatoria del
##            "Trabajador del Ministerio" como ÚLTIMO visitante del día.
##   Día 4 -> MODIFICADO: se agrega high_tide_anomalies + forced_hidden_items
##            (objetos de lore en baúles random).
##   Día 5 -> NUEVO: clímax, inyección obligatoria del "Hombre sin rostro"
##            como ÚLTIMO visitante del día.
##
## Los pools de Día 3 y Día 4 venían vacíos en la versión original (dejaban
## weight_medium/weight_complex > 0 sin nada cargado en medium_pool/complex_pool,
## lo que rompe VisitorSpawner._pick_from_pool). Se completan acá con
## perfiles mínimos de ejemplo para que la cola se arme sin errores; en el
## juego real conviene reemplazarlos por los .tres del Inspector.

static func build_day_1() -> DayConfig:
	var doc_dni := DocumentData.new()
	doc_dni.document_type = DocumentData.DocType.DNI
	doc_dni.holder_name = "Marta Coliqueo"
	doc_dni.document_number = "18.204.556"

	var doc_pase := DocumentData.new()
	doc_pase.document_type = DocumentData.DocType.PASE_DIARIO
	doc_pase.expires_on_day = 1

	var visitante := VisitorProfile.new()
	visitante.visitor_id = "day1_turista_marta"
	visitante.visitor_name = "Marta Coliqueo"
	visitante.tier = VisitorProfile.VisitorTier.SIMPLE
	visitante.dialog_intro = "Buen día, vengo a caminar el sendero de la costa."
	visitante.documents = [doc_dni, doc_pase]
	visitante.should_be_approved = true
	visitante.authorized_passengers = 2
	visitante.job_permit_label = "Ninguno (Particular)"
	visitante.fire_permit = false
	visitante.fishing_permit = false

	var day := DayConfig.new()
	day.day_number = 1
	day.total_visitors = 8
	day.day_title = "Boletín Diario - Día 1"
	day.season_label = "Verano austral"
	day.weather_description = "Despejado, viento leve del oeste, 14°C"
	day.fire_risk_label = "BAJO"
	day.fire_risk_color = Color(0.4, 0.85, 0.4)
	day.protected_fauna_note = "Ninguna alerta activa en Costa y Pingüinera"
	day.rules_summary = [
		"Todo visitante debe presentar DNI vigente.",
		"El Pase Diario vence al finalizar la jornada de ingreso.",
		"Prohibido el ingreso sin documentación completa."
	]
	day.simple_pool = [visitante] # en el juego real: 4-6 perfiles distintos
	day.weight_simple = 1.0
	day.weight_medium = 0.0
	day.weight_complex = 0.0
	return day

## NUEVO: Día 2 — introduce Medium y la inyección obligatoria del
## "Pescador Raro" (baúl con Espécimen Marino Mutado).
static func build_day_2() -> DayConfig:
	# --- Pools normales del día (contenido mínimo de ejemplo) ---
	var doc_turista := DocumentData.new()
	doc_turista.document_type = DocumentData.DocType.PASE_DIARIO
	doc_turista.holder_name = "Osvaldo Millán"
	doc_turista.expires_on_day = 2

	var turista := VisitorProfile.new()
	turista.visitor_id = "day2_turista_osvaldo"
	turista.visitor_name = "Osvaldo Millán"
	turista.tier = VisitorProfile.VisitorTier.SIMPLE
	turista.dialog_intro = "Buenas, venimos a hacer un asado en la costa."
	turista.documents = [doc_turista]
	turista.should_be_approved = true
	turista.authorized_passengers = 3
	turista.car_items = ["Bolsa de carbón 10kg", "Parrilla portátil"]

	var doc_cientifica := DocumentData.new()
	doc_cientifica.document_type = DocumentData.DocType.PERMISO_ACTIVIDAD
	doc_cientifica.holder_name = "Bárbara Sued"
	doc_cientifica.authorized_activity = DocumentData.Activity.INVESTIGACION_CIENTIFICA
	doc_cientifica.expires_on_day = 2

	var investigadora := VisitorProfile.new()
	investigadora.visitor_id = "day2_investigadora_barbara"
	investigadora.visitor_name = "Bárbara Sued"
	investigadora.tier = VisitorProfile.VisitorTier.MEDIUM
	investigadora.dialog_intro = "Vengo a hacer el conteo de pingüinos de esta temporada."
	investigadora.documents = [doc_cientifica]
	investigadora.should_be_approved = true
	investigadora.authorized_passengers = 2
	investigadora.car_items = ["Binoculares astronómicos", "Planillas de conteo de aves"]

	# --- NUEVO: Inyección obligatoria narrativa: el "Pescador Raro" ---
	var doc_pesca := DocumentData.new()
	doc_pesca.document_type = DocumentData.DocType.PERMISO_ACTIVIDAD
	doc_pesca.holder_name = "Custodio Paillao"
	doc_pesca.document_number = "14.887.230"
	doc_pesca.authorized_activity = DocumentData.Activity.PESCA_DEPORTIVA
	doc_pesca.expires_on_day = 2
	# El documento en sí está en regla; lo anómalo es lo que trae en el baúl.
	doc_pesca.is_anomalous_document = true

	var pescador_raro := VisitorProfile.new()
	pescador_raro.visitor_id = "day2_pescador_raro"
	pescador_raro.visitor_name = "Custodio Paillao"
	pescador_raro.tier = VisitorProfile.VisitorTier.LORE_ANOMALY
	pescador_raro.narrative_key = "day2_pescador_raro" # NUEVO: clave narrativa
	pescador_raro.dialog_intro = "Buena pesca hoy, oficial. Rarísima, pero buena."
	pescador_raro.dialog_interrogate = "Eso lo saqué del fondo, cerca de las rocas. Nunca vi nada igual."
	pescador_raro.documents = [doc_pesca]
	pescador_raro.should_be_approved = true # el permiso en sí es válido
	pescador_raro.authorized_passengers = 1
	pescador_raro.car_items = ["2 Cañas de pescar telescópicas", "Conservadora con hielo"]
	# NUEVO: objeto de lore obligatorio de este visitante (Día 2).
	pescador_raro.hidden_items = ["Espécimen Marino Mutado"]

	var evento_pescador := ForcedLoreEvent.new()
	evento_pescador.spawn_index = 4 # a mitad de jornada, no en warm-up ni al cierre
	evento_pescador.visitor = pescador_raro

	var day := DayConfig.new()
	day.day_number = 2
	day.total_visitors = 8
	day.day_title = "Boletín Diario - Día 2"
	day.season_label = "Verano austral"
	day.weather_description = "Parcialmente nublado, mar picado, 12°C"
	day.fire_risk_label = "BAJO"
	day.fire_risk_color = Color(0.4, 0.85, 0.4)
	day.protected_fauna_note = "Reporte de fauna marina inusual en la costa"
	day.rules_summary = [
		"Todo Permiso de Actividad debe coincidir con lo hallado en el baúl.",
		"Reportar cualquier espécimen o hallazgo fuera de catálogo a la Administración.",
		"El Permiso de Pesca Deportiva no exime la inspección del vehículo."
	]
	day.simple_pool = [turista]
	day.medium_pool = [investigadora]
	day.forced_lore_events = [evento_pescador]
	day.weight_simple = 0.65
	day.weight_medium = 0.35
	day.weight_complex = 0.0
	return day

static func build_day_3() -> DayConfig:
	# --- Pools normales del día (contenido mínimo de ejemplo) ---
	var doc_simple := DocumentData.new()
	doc_simple.document_type = DocumentData.DocType.PASE_DIARIO
	doc_simple.holder_name = "Delia Antinao"
	doc_simple.expires_on_day = 3

	var visitante_simple := VisitorProfile.new()
	visitante_simple.visitor_id = "day3_visitante_delia"
	visitante_simple.visitor_name = "Delia Antinao"
	visitante_simple.tier = VisitorProfile.VisitorTier.SIMPLE
	visitante_simple.dialog_intro = "Buenas tardes, veníamos a caminar antes de que oscurezca."
	visitante_simple.documents = [doc_simple]
	visitante_simple.should_be_approved = true
	visitante_simple.authorized_passengers = 2

	var doc_pase := DocumentData.new()
	doc_pase.document_type = DocumentData.DocType.PASE_DIARIO
	doc_pase.holder_name = "Aníbal Reyes"
	doc_pase.expires_on_day = 3

	var fotografo := VisitorProfile.new()
	fotografo.visitor_id = "day3_fotografo_nocturno"
	fotografo.visitor_name = "Aníbal Reyes"
	fotografo.tier = VisitorProfile.VisitorTier.LORE_ANOMALY
	fotografo.dialog_intro = "Solo quiero un par de fotos del faro. No tardo nada."
	fotografo.dialog_interrogate = "..." # no parpadea — clave de puesta en escena/animación
	fotografo.documents = [doc_pase]
	fotografo.should_be_approved = false # Pase Diario no habilita ingreso nocturno
	fotografo.rejection_reasons = ["Pase Diario no autoriza permanencia nocturna"]
	fotografo.authorized_passengers = 1
	fotografo.job_permit_label = "Ninguno (Particular)"
	fotografo.fire_permit = false
	fotografo.fishing_permit = false

	var evento_fotografo := ForcedLoreEvent.new()
	evento_fotografo.spawn_index = 3
	evento_fotografo.visitor = fotografo

	# --- NUEVO: Inyección obligatoria narrativa: "Trabajador del Ministerio",
	# SIEMPRE como último visitante del día (spawn_index = total_visitors - 1).
	var total_visitors_day3 := 10

	var doc_invalido := DocumentData.new()
	doc_invalido.document_type = DocumentData.DocType.PERMISO_ACTIVIDAD
	doc_invalido.holder_name = "Trabajador del Ministerio"
	doc_invalido.document_number = "" # llega sin documentación válida
	doc_invalido.expiration_date_display = "-- SIN DATOS --"
	doc_invalido.expires_on_day = 0 # ya vencido para cualquier día de la partida
	doc_invalido.authorized_activity = DocumentData.Activity.MANTENIMIENTO_PARQUE
	doc_invalido.is_anomalous_document = true

	var trabajador_ministerio := VisitorProfile.new()
	trabajador_ministerio.visitor_id = "day3_trabajador_ministerio"
	trabajador_ministerio.visitor_name = "Trabajador del Ministerio"
	trabajador_ministerio.tier = VisitorProfile.VisitorTier.LORE_ANOMALY
	trabajador_ministerio.narrative_key = "day3_trabajador_ministerio" # NUEVO
	trabajador_ministerio.dialog_intro = "Trámite de rutina, oficial. Ya debería estar autorizado."
	trabajador_ministerio.dialog_interrogate = "No necesito explicarle nada a un reemplazo."
	trabajador_ministerio.documents = [doc_invalido]
	trabajador_ministerio.should_be_approved = false
	trabajador_ministerio.rejection_reasons = ["No presenta documentación válida"]
	trabajador_ministerio.authorized_passengers = 1
	trabajador_ministerio.job_permit_label = "Ministerio (no verificable)"

	var evento_ministerio := ForcedLoreEvent.new()
	evento_ministerio.spawn_index = total_visitors_day3 - 1 # NUEVO: último del día
	evento_ministerio.visitor = trabajador_ministerio

	var day := DayConfig.new()
	day.day_number = 3
	day.total_visitors = total_visitors_day3
	day.day_title = "Boletín Diario - Día 3"
	day.season_label = "Otoño patagónico"
	day.weather_description = "Neblina costera al anochecer, 6°C"
	day.fire_risk_label = "MEDIO"
	day.fire_risk_color = Color(0.95, 0.8, 0.3)
	day.protected_fauna_note = "Restricción de circulación nocturna cerca del faro"
	day.rules_summary = [
		"El Pase Diario no habilita permanencia después del ocaso.",
		"Reportar cualquier visitante que insista en ingresar de noche.",
		"Ante documentación irregular, denegar el paso y registrar el motivo."
	]
	day.simple_pool = [visitante_simple]
	day.medium_pool = [visitante_simple] # ejemplo mínimo: reemplazar por perfiles Medium reales
	day.forced_lore_events = [evento_fotografo, evento_ministerio]
	day.weight_simple = 0.5
	day.weight_medium = 0.4
	day.weight_complex = 0.1
	day.is_foggy = true # NUEVO: efecto ambiental del Día 3
	return day

static func build_day_4() -> DayConfig:
	# --- Pools normales del día (contenido mínimo de ejemplo) ---
	var doc_guia := DocumentData.new()
	doc_guia.document_type = DocumentData.DocType.PERMISO_ACTIVIDAD
	doc_guia.holder_name = "Nicasio Huenul"
	doc_guia.authorized_activity = DocumentData.Activity.TRAVESIA_SENDERISMO
	doc_guia.expires_on_day = 4

	var guia_turistico := VisitorProfile.new()
	guia_turistico.visitor_id = "day4_guia_nicasio"
	guia_turistico.visitor_name = "Nicasio Huenul"
	guia_turistico.tier = VisitorProfile.VisitorTier.SIMPLE
	guia_turistico.dialog_intro = "Grupo chico hoy, casi no se ve nada con este viento."
	guia_turistico.documents = [doc_guia]
	guia_turistico.should_be_approved = true
	guia_turistico.authorized_passengers = 4
	guia_turistico.car_items = ["Botiquín de primeros auxilios", "Folletos informativos del parque"]

	var doc_falso := DocumentData.new()
	doc_falso.document_type = DocumentData.DocType.PERMISO_ACTIVIDAD
	doc_falso.holder_name = "Ricardo Fabbiani"
	doc_falso.authorized_activity = DocumentData.Activity.INVESTIGACION_CIENTIFICA
	doc_falso.signed_by = "Silva" # firma imposible: Silva desapareció
	doc_falso.has_black_seal = true
	doc_falso.is_anomalous_document = true

	var agente := VisitorProfile.new()
	agente.visitor_id = "day4_falso_agente_ministerio"
	agente.visitor_name = "Ricardo Fabbiani"
	agente.tier = VisitorProfile.VisitorTier.LORE_ANOMALY
	agente.dialog_intro = "Agente del Ministerio. Vengo autorizado por el guardaparques Silva."
	agente.documents = [doc_falso]
	agente.should_be_approved = false
	agente.rejection_reasons = ["Firma de un guardaparques desaparecido", "Sello no catalogado"]
	agente.authorized_passengers = 1
	agente.job_permit_label = "Agente Ministerial (no verificable)"
	agente.fire_permit = false
	agente.fishing_permit = false

	var evento := ForcedLoreEvent.new()
	evento.spawn_index = 4
	evento.visitor = agente

	var day := DayConfig.new()
	day.day_number = 4
	day.total_visitors = 10
	day.day_title = "Boletín Diario - Día 4"
	day.season_label = "Invierno costero"
	day.weather_description = "Viento patagónico intenso, 2°C"
	day.fire_risk_label = "ALTO"
	day.fire_risk_color = Color(0.95, 0.35, 0.3)
	day.protected_fauna_note = "Cierre preventivo de Humedal y Laguna de Aves"
	day.rules_summary = [
		"Ningún documento firmado por 'Silva' es válido desde su desaparición.",
		"El sello negro no corresponde a ninguna autoridad catalogada: rechazar y reportar.",
		"Ante sospecha de suplantación, denegar el paso sin excepciones."
	]
	day.simple_pool = [guia_turistico]
	day.medium_pool = [guia_turistico] # ejemplo mínimo: reemplazar por perfiles Medium reales
	day.forced_lore_events = [evento]
	# NUEVO: objetos de lore garantizados en baúles random del día (no del
	# agente falso, que ya es su propio evento narrativo).
	day.forced_hidden_items = ["Foto de Mr. Chenque de 1920", "Mapa de túneles del Chenque"]
	day.weight_simple = 0.3
	day.weight_medium = 0.4
	day.weight_complex = 0.3
	day.high_tide_anomalies = true # NUEVO: efecto ambiental del Día 4
	return day

## NUEVO: Día 5 — Clímax. Inyección obligatoria del "Hombre sin rostro"
## como ÚLTIMO visitante del día. Su decisión define el final del juego.
static func build_day_5() -> DayConfig:
	# --- Pools normales del día (contenido mínimo de ejemplo) ---
	var doc_ultimo_dia := DocumentData.new()
	doc_ultimo_dia.document_type = DocumentData.DocType.PASE_DIARIO
	doc_ultimo_dia.holder_name = "Felisa Currumil"
	doc_ultimo_dia.expires_on_day = 5

	var visitante_final := VisitorProfile.new()
	visitante_final.visitor_id = "day5_visitante_felisa"
	visitante_final.visitor_name = "Felisa Currumil"
	visitante_final.tier = VisitorProfile.VisitorTier.SIMPLE
	visitante_final.dialog_intro = "Venimos a despedir la temporada, oficial."
	visitante_final.documents = [doc_ultimo_dia]
	visitante_final.should_be_approved = true
	visitante_final.authorized_passengers = 2

	# --- NUEVO: Inyección obligatoria narrativa: "Hombre sin rostro",
	# SIEMPRE como último visitante del día (spawn_index = total_visitors - 1).
	var total_visitors_day5 := 8

	var doc_1980 := DocumentData.new()
	doc_1980.document_type = DocumentData.DocType.PERMISO_ACTIVIDAD
	doc_1980.holder_name = "??? (sin rostro visible)"
	doc_1980.document_number = "00.000.000"
	doc_1980.authorized_activity = DocumentData.Activity.MANTENIMIENTO_PARQUE
	doc_1980.expiration_date_display = "31/12/1980" # caducado en 1980
	doc_1980.expires_on_day = 0 # vencido para cualquier día jugable
	doc_1980.signed_by = "Chenque" # NUEVO: mismo apellido que el jugador
	doc_1980.signed_by_chenque = true # NUEVO: flag dedicada de lore
	doc_1980.has_black_seal = true
	doc_1980.is_anomalous_document = true

	var hombre_sin_rostro := VisitorProfile.new()
	hombre_sin_rostro.visitor_id = "day5_hombre_sin_rostro"
	hombre_sin_rostro.visitor_name = "Hombre sin rostro"
	hombre_sin_rostro.tier = VisitorProfile.VisitorTier.LORE_ANOMALY
	hombre_sin_rostro.narrative_key = "day5_hombre_sin_rostro" # NUEVO
	hombre_sin_rostro.dialog_intro = "Ya estuve acá antes, oficial. Antes de que usted naciera."
	hombre_sin_rostro.dialog_interrogate = "El apellido en ese sello no es casualidad, Chenque."
	hombre_sin_rostro.documents = [doc_1980]
	hombre_sin_rostro.should_be_approved = false
	hombre_sin_rostro.rejection_reasons = [
		"Documento caducado desde 1980",
		"Firma imposible: emitido por un 'Chenque' antes de la llegada de Mr. Chenque"
	]
	hombre_sin_rostro.authorized_passengers = 1
	hombre_sin_rostro.avatar_file = "" # a propósito: sin avatar, "sin rostro"

	var evento := ForcedLoreEvent.new()
	evento.spawn_index = total_visitors_day5 - 1 # NUEVO: último del día, clímax
	evento.visitor = hombre_sin_rostro

	var day := DayConfig.new()
	day.day_number = 5
	day.total_visitors = total_visitors_day5
	day.day_title = "Boletín Diario - Día 5 (Cierre de Temporada)"
	day.season_label = "Fin de temporada"
	day.weather_description = "Calma extraña, sin viento, 4°C"
	day.fire_risk_label = "MEDIO"
	day.fire_risk_color = Color(0.95, 0.8, 0.3)
	day.protected_fauna_note = "Silencio inusual reportado en toda la costa"
	day.rules_summary = [
		"Último día de temporada: revisar doble toda documentación antes de sellar.",
		"Ningún documento anterior a la fundación del parque es válido.",
		"Ante cualquier duda, la decisión final queda a criterio del oficial de turno."
	]
	day.simple_pool = [visitante_final]
	day.forced_lore_events = [evento]
	day.weight_simple = 0.7
	day.weight_medium = 0.3
	day.weight_complex = 0.0
	return day
