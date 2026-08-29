extends Node
class_name DataDB

# Base de Datos Completa de Reglas, Clima, y 20 Visitantes con Imágenes en /public (5 Días x 4 Visitantes)

static func get_day_info(day_number: int) -> Dictionary:
	match day_number:
		1:
			return {
				"title": "Día 1: Primavera Ventosa en la Costa Patagónica",
				"season": "Primavera",
				"weather": "Viento O/SO 50 km/h - Parcialmente nublado - 15°C",
				"fire_risk": "MEDIO",
				"fire_risk_color": Color(0.95, 0.75, 0.2),
				"protected_fauna": "Pingüinos de Magallanes (Anidación en Costa) y Aves Marinas",
				"rules_summary": [
					"Todo visitante debe portar 'Pase de Ingreso' con fecha vigente.",
					"Fuego permitido ÚNICAMENTE con 'Permiso de Fuego/Fogón' explícito.",
					"Prohibido acampar en zonas protegidas sin 'Permiso de Acampe'.",
					"Cantidad de personas en el auto debe coincidir con el permiso declarado.",
					"Revisar el baúl para detectar leña o carbón no autorizados."
				]
			}
		2:
			return {
				"title": "Día 2: Verano Seco - Alerta por Fuego y Control de Pesca",
				"season": "Verano",
				"weather": "Viento N 35 km/h - Clima muy seco y soleado - 27°C",
				"fire_risk": "ALTO",
				"fire_risk_color": Color(0.95, 0.45, 0.15),
				"protected_fauna": "Guanacos en faldeos del Chenque y Pingüinos en playa",
				"rules_summary": [
					"⚠️ ALERTA POR SEQUÍA: PROHIBIDO TODO TIPO DE FUEGO O CARBÓN (Incluso con permiso anterior).",
					"Pesca deportiva permitida ÚNICAMENTE con 'Permiso de Pesca Provincial'.",
					"Prohibidas las redes agalleras y arpones furtivos.",
					"Guías y personal turístico deben presentar 'Permiso de Oficio'."
				]
			}
		3:
			return {
				"title": "Día 3: Alerta Roja por Temporal de Viento Extremo",
				"season": "Verano Tardío",
				"weather": "Viento O/NO 90 km/h (Temporal Patagónico) - Polvo y Sequedad - 29°C",
				"fire_risk": "EXTREMO",
				"fire_risk_color": Color(0.9, 0.15, 0.15),
				"protected_fauna": "Zorros Colorados y Petreles Gigantes en Acantilados",
				"rules_summary": [
					"🚨 RIESGO EXTREMO: Prohibición total de motosierras, hachas, leña y bidones de combustible.",
					"Prohibido el ingreso de más de 4 personas por auto por evacuación preventiva.",
					"Revisar estrictamente la fecha de caducidad del documento.",
					"Cualquier elemento de tala o combustión es causal de rechazo inmediato."
				]
			}
		4:
			return {
				"title": "Día 4: Preservación de Acantilados y Chalet Histórico",
				"season": "Otoño Inicial",
				"weather": "Viento S 40 km/h - Frío y lloviznas intermitentes - 11°C",
				"fire_risk": "BAJO",
				"fire_risk_color": Color(0.2, 0.75, 0.3),
				"protected_fauna": "Arbolado Histórico del Chalet y Aves de Humedal",
				"rules_summary": [
					"PROHIBICIÓN ESTRICTA DE CAZA: Rifles, gomeras, trampas o jaulas = RECHAZO.",
					"Prohibido transportar materiales de construcción (chapas, postes, alambre de púa) sin orden de catastro (Riesgo de usurpación).",
					"Mascotas permitidas únicamente con correa reglamentaria para proteger la fauna.",
					"Verificar que la fotografía y datos del documento coincidan con el visitante."
				]
			}
		5:
			return {
				"title": "Día 5: Día de Inspección General y Auditoría",
				"season": "Otoño Pleno",
				"weather": "Viento SO 65 km/h - Helada matinal y cielo despejado - 7°C",
				"fire_risk": "MEDIO",
				"fire_risk_color": Color(0.95, 0.75, 0.2),
				"protected_fauna": "Toda la Reserva Natural Chalet Huergo y Humedales",
				"rules_summary": [
					"APLICAR TODAS LAS NORMAS VIGENTES DE CONTROL.",
					"Fuego: Solo con Permiso de Fuego explícito.",
					"Pesca: Solo con Permiso de Pesca habilitado.",
					"Oficios y Servicios: Requerir 'Permiso de Oficio / Credencial Ministerial' oficial.",
					"Atención a documentos adulterados o falsos inspectores."
				]
			}
		_:
			return {}

static func get_visitors_for_day(day_number: int) -> Array[Dictionary]:
	match day_number:
		1:
			return [
				{
					"name": "Nahuel Morales",
					"avatar_file": "fotografoSinParpadeo.jpg",
					"car_name": "Renault 12 Celeste",
					"car_color": Color(0.4, 0.6, 0.8),
					"declared_passengers": 2,
					"actual_passengers": 2,
					"dialog_intro": "Buenas tardes oficial Chenque. Venimos a sacar unas fotos de los senderos y el mirador costero.",
					"dialog_interrogate": "¿Alguna duda? Todo en orden, solo traemos un termo de mate y la cámara réflex.",
					"doc": {
						"name": "Nahuel Morales",
						"dni": "34.892.110",
						"type": "Pase de Ingreso Diario",
						"date": "28/11/2026",
						"purpose": "Turismo y Fotografía",
						"passengers": 2,
						"fire_permit": false,
						"fishing_permit": false,
						"job_permit": "Ninguno (Particular)",
						"is_expired": false
					},
					"car_items": ["Cámara de fotos réflex", "Termo y mate patagónico", "Mochila con abrigos"],
					"should_pass": true,
					"rejection_reasons": [],
					"parcel_impact": {}
				},
				{
					"name": "Rodrigo 'El Asador' Vega",
					"avatar_file": "camionConSobrePesoDeLeña.jpg",
					"car_name": "Ford F-100 Oxidada",
					"car_color": Color(0.7, 0.35, 0.2),
					"declared_passengers": 3,
					"actual_passengers": 3,
					"dialog_intro": "¡Hola Don Chenque! Venimos a tirar una carnecita al pasto con los muchachos.",
					"dialog_interrogate": "¿Permiso de fuego? ¿Para qué tanto papel? Traje dos bolsas de quebracho y una parrilla portátil.",
					"doc": {
						"name": "Rodrigo Vega",
						"dni": "28.331.405",
						"type": "Pase de Ingreso Diario",
						"date": "28/11/2026",
						"purpose": "Paseo Familiar",
						"passengers": 3,
						"fire_permit": false, # NO TIENE PERMISO DE FUEGO
						"fishing_permit": false,
						"job_permit": "Ninguno",
						"is_expired": false
					},
					"car_items": ["Bolsa de carbón 10kg", "Parrilla portátil", "Bidón de leña de quebracho"],
					"should_pass": false,
					"rejection_reasons": ["Trae carbón y leña sin 'Permiso de Fuego' habilitado"],
					"parcel_impact": {
						"Bosque de Lengas": {"damage": 30.0, "tag": "incendio"}
					}
				},
				{
					"name": "Silvina Aonikenk",
					"avatar_file": "acampanteIndebido.jpg",
					"car_name": "Volkswagen Gol Blanco",
					"car_color": Color(0.9, 0.9, 0.92),
					"declared_passengers": 1,
					"actual_passengers": 3, # Discrepancia grave
					"dialog_intro": "Buenas. Vengo yo sola a hacer una caminata tranquila por el humedal.",
					"dialog_interrogate": "Eh... los que van atrás son unos amigos que levanté en la ruta con carpas, ¿no pueden pasar?",
					"doc": {
						"name": "Silvina Aonikenk",
						"dni": "39.120.441",
						"type": "Pase de Ingreso Diario",
						"date": "28/11/2026",
						"purpose": "Trekking Individual",
						"passengers": 1,
						"fire_permit": false,
						"fishing_permit": false,
						"job_permit": "Ninguno",
						"is_expired": false
					},
					"car_items": ["Carpa iglú 4 personas", "Bolsas de dormir", "2 Pasajeros escondidos en asiento trasero"],
					"should_pass": false,
					"rejection_reasons": [
						"Discrepancia de pasajeros (3 reales vs 1 en pase)",
						"Elementos de acampe ilegal en humedal protegido"
					],
					"parcel_impact": {
						"Humedal y Laguna de Aves": {"damage": 25.0, "tag": "acampe"}
					}
				},
				{
					"name": "Dr. Fernando Caleta",
					"avatar_file": "investigadorDeLaboratorio.jpg",
					"car_name": "Toyota Hilux Verde",
					"car_color": Color(0.25, 0.45, 0.3),
					"declared_passengers": 2,
					"actual_passengers": 2,
					"dialog_intro": "Buenas tardes guardaparque. Somos biólogos de la universidad para realizar el censo de aves.",
					"dialog_interrogate": "Tenemos el pase científico universitario y la credencial de laboratorio al día.",
					"doc": {
						"name": "Dr. Fernando Caleta",
						"dni": "22.650.980",
						"type": "Pase Científico / Oficial",
						"date": "28/11/2026",
						"purpose": "Investigación y Censo de Aves",
						"passengers": 2,
						"fire_permit": true,
						"fishing_permit": false,
						"job_permit": "Biólogo Investigador",
						"is_expired": false
					},
					"car_items": ["Binoculares astronómicos", "Planillas de conteo de aves", "Termo de café"],
					"should_pass": true,
					"rejection_reasons": [],
					"parcel_impact": {}
				}
			]
		2:
			return [
				{
					"name": "Lautaro Pejerrey",
					"avatar_file": "pescadorDeProfundidad.jpg",
					"car_name": "Fiat Duna Rojo",
					"car_color": Color(0.8, 0.25, 0.2),
					"declared_passengers": 2,
					"actual_passengers": 2,
					"dialog_intro": "¡Qué tal jefe! Un hermoso día para probar suerte en la costa con las cañas reglamentarias.",
					"dialog_interrogate": "Tengo el carnet de pesca provincial al día, anzuelos simples y conservadora limpia.",
					"doc": {
						"name": "Lautaro Pejerrey",
						"dni": "31.442.809",
						"type": "Permiso de Pesca Provincial",
						"date": "28/11/2026",
						"purpose": "Pesca Deportiva de Costa",
						"passengers": 2,
						"fire_permit": false,
						"fishing_permit": true, # Habilitado
						"job_permit": "Pescador Deportivo Registrado",
						"is_expired": false
					},
					"car_items": ["2 Cañas de pescar telescópicas", "Caja de señuelos reglamentarios", "Conservadora con hielo"],
					"should_pass": true,
					"rejection_reasons": [],
					"parcel_impact": {}
				},
				{
					"name": "Esteban Cruz",
					"avatar_file": "residenteKm3.jpg",
					"car_name": "Peugeot 504 Gris",
					"car_color": Color(0.6, 0.6, 0.65),
					"declared_passengers": 4,
					"actual_passengers": 4,
					"dialog_intro": "Hola Don Chenque, soy vecino de Km 3. Traigo un costillar para hacer fuego en las mesas.",
					"dialog_interrogate": "¿Pero cómo que no se puede prender fuego hoy? ¡Mire que tengo el pase sellado!",
					"doc": {
						"name": "Esteban Cruz",
						"dni": "26.778.112",
						"type": "Pase de Ingreso Diario",
						"date": "28/11/2026",
						"purpose": "Asado Familiar",
						"passengers": 4,
						"fire_permit": true, # Inválido hoy por ALERTA ALTO
						"fishing_permit": false,
						"job_permit": "Ninguno",
						"is_expired": false
					},
					"car_items": ["Bolsas de carbón vegetal", "Parrilla de hierro", "Botella de alcohol de quemar"],
					"should_pass": false,
					"rejection_reasons": ["Riesgo ALTO de incendio por sequía: FUEGO TOTALMENTE PROHIBIDO"],
					"parcel_impact": {
						"Bosque de Lengas": {"damage": 35.0, "tag": "incendio"}
					}
				},
				{
					"name": "Marcos Furtivo",
					"avatar_file": "pescadorEnVeda.jpg",
					"car_name": "Chevrolet Corsa Verde",
					"car_color": Color(0.3, 0.5, 0.35),
					"declared_passengers": 2,
					"actual_passengers": 2,
					"dialog_intro": "Buenas tardes. Solo venimos a tomar mate y ver las olas en la restinga.",
					"dialog_interrogate": "¿Esas redes en el baúl? No son mías... me las olvidé en el viaje pasado...",
					"doc": {
						"name": "Marcos Furtivo",
						"dni": "35.109.870",
						"type": "Pase de Ingreso Diario",
						"date": "28/11/2026",
						"purpose": "Paseo Costero",
						"passengers": 2,
						"fire_permit": false,
						"fishing_permit": false, # NO HABILITADO
						"job_permit": "Ninguno",
						"is_expired": false
					},
					"car_items": ["3 Redes agalleras ilegales", "Cañas de pescar ocultas", "Cuchillos de desvicerar"],
					"should_pass": false,
					"rejection_reasons": ["Pesca ilegal sin carnet y uso de redes agalleras prohibidas"],
					"parcel_impact": {
						"Costa y Pingüinera": {"damage": 35.0, "tag": "pesca_furtiva"}
					}
				},
				{
					"name": "Martina Almada",
					"avatar_file": "guiaAutorizada.jpg",
					"car_name": "Minibús Mercedes Blanco",
					"car_color": Color(0.9, 0.9, 0.95),
					"declared_passengers": 4,
					"actual_passengers": 4,
					"dialog_intro": "Buen día Mr. Chenque. Traigo un grupo de turistas para el circuito histórico y pingüinera.",
					"dialog_interrogate": "Tengo mi credencial de guía habilitada por Parques Nacionales y botiquín de primeros auxilios.",
					"doc": {
						"name": "Martina Almada",
						"dni": "32.114.770",
						"type": "Pase de Guía Oficial de Turismo",
						"date": "28/11/2026",
						"purpose": "Excursión Guiada Oficial",
						"passengers": 4,
						"fire_permit": false,
						"fishing_permit": false,
						"job_permit": "Guía Oficial de Turismo Habilitada",
						"is_expired": false
					},
					"car_items": ["Botiquín de primeros auxilios", "Megáfono de guiada", "Folletos informativos del parque"],
					"should_pass": true,
					"rejection_reasons": [],
					"parcel_impact": {}
				}
			]
		3:
			return [
				{
					"name": "Héctor 'Hacha' Leiva",
					"avatar_file": "recolectorDeFlora.jpg",
					"car_name": "Camioneta Ranger Vieja",
					"car_color": Color(0.45, 0.35, 0.25),
					"declared_passengers": 2,
					"actual_passengers": 2,
					"dialog_intro": "Buenas paisano. Vamos a juntar unas ramas secas caídas al fondo del bosque de lengas.",
					"dialog_interrogate": "¿La motosierra y el bidón? Para ramas caídas nomás, no desconfíe oficial.",
					"doc": {
						"name": "Héctor Leiva",
						"dni": "21.908.761",
						"type": "Pase de Ingreso Diario",
						"date": "28/11/2026",
						"purpose": "Recolección de Leña",
						"passengers": 2,
						"fire_permit": false,
						"fishing_permit": false,
						"job_permit": "Ninguno",
						"is_expired": false
					},
					"car_items": ["Motosierra Stihl a nafta", "Bidón de combustible 20L", "Hacha de tala de doble filo", "Cadenas de arrastre"],
					"should_pass": false,
					"rejection_reasons": ["Riesgo EXTREMO: Prohibidas motosierras, combustible y hachas (Tala/Incendio)"],
					"parcel_impact": {
						"Bosque de Lengas": {"damage": 45.0, "tag": "tala"}
					}
				},
				{
					"name": "Valeria Fontana",
					"avatar_file": "historiadora.jpg",
					"car_name": "Honda Fit Gris",
					"car_color": Color(0.7, 0.72, 0.75),
					"declared_passengers": 3,
					"actual_passengers": 3,
					"dialog_intro": "Hola guardaparque Chenque. Venimos a relevar archivos y fotografías al museo del Chalet.",
					"dialog_interrogate": "Traemos únicamente viandas frías, termos y libretas de investigación histórica.",
					"doc": {
						"name": "Valeria Fontana",
						"dni": "36.430.198",
						"type": "Pase de Ingreso Diario",
						"date": "28/11/2026",
						"purpose": "Investigación Histórica Chalet Huergo",
						"passengers": 3,
						"fire_permit": false,
						"fishing_permit": false,
						"job_permit": "Investigadora de Patrimonio",
						"is_expired": false
					},
					"car_items": ["Sándwiches fríos", "Libretas de notas", "Grabador de periodista", "Cámara fotográfica"],
					"should_pass": true,
					"rejection_reasons": [],
					"parcel_impact": {}
				},
				{
					"name": "Gastón Peligroso",
					"avatar_file": "conductorPeligroso.jpg",
					"car_name": "Volkswagen Senda Azul",
					"car_color": Color(0.2, 0.3, 0.6),
					"declared_passengers": 5,
					"actual_passengers": 5, # Excede límite de 4 en temporal
					"dialog_intro": "¡Buenas jefe! Apúrese que queremos subir al mirador del cerro antes que sople más viento.",
					"dialog_interrogate": "¿La fecha? Ah, es el pase del mes pasado... pensé que servía igual...",
					"doc": {
						"name": "Gastón Méndez",
						"dni": "29.800.123",
						"type": "Pase de Ingreso Diario",
						"date": "14/10/2026", # VENCIDO
						"purpose": "Turismo en Mirador",
						"passengers": 5,
						"fire_permit": false,
						"fishing_permit": false,
						"job_permit": "Ninguno",
						"is_expired": true
					},
					"car_items": ["Botellas de cerveza abiertas", "5 Pasajeros amontonados sin cinturón"],
					"should_pass": false,
					"rejection_reasons": [
						"Pase de ingreso VENCIDO (14/10/2026)",
						"Supera límite de 4 pasajeros en alerta por temporal"
					],
					"parcel_impact": {
						"Cerro Chenque y Acantilados": {"damage": 30.0, "tag": "usurpacion"}
					}
				},
				{
					"name": "Lucía Deporte",
					"avatar_file": "deportistaLocal.jpg",
					"car_name": "Ford Ka Rojo",
					"car_color": Color(0.85, 0.2, 0.2),
					"declared_passengers": 1,
					"actual_passengers": 1,
					"dialog_intro": "Hola Mr. Chenque. Vengo a hacer entrenamiento de cross-country por el sendero habilitado.",
					"dialog_interrogate": "Tengo el carnet deportivo municipal y solo llevo hidratación y zapatillas de recambio.",
					"doc": {
						"name": "Lucía Deporte",
						"dni": "38.221.905",
						"type": "Pase Deportivo Municipal",
						"date": "28/11/2026",
						"purpose": "Entrenamiento Trail Running",
						"passengers": 1,
						"fire_permit": false,
						"fishing_permit": false,
						"job_permit": "Atleta Federada",
						"is_expired": false
					},
					"car_items": ["Mochila de hidratación", "Zapatillas de trail", "Reloj pulsómetro"],
					"should_pass": true,
					"rejection_reasons": [],
					"parcel_impact": {}
				}
			]
		4:
			return [
				{
					"name": "Mauro 'El Trampero' Solís",
					"avatar_file": "cazadorFurtivo.jpg",
					"car_name": "Jeep Ika Negro",
					"car_color": Color(0.2, 0.2, 0.2),
					"declared_passengers": 2,
					"actual_passengers": 2,
					"dialog_intro": "Buenas. Venimos a recorrer los cañadones del Cerro Chenque.",
					"dialog_interrogate": "¿Ese bulto envuelto en la lona? Son herramientas mecánicas nomás...",
					"doc": {
						"name": "Mauro Solís",
						"dni": "25.667.890",
						"type": "Pase de Ingreso Diario",
						"date": "28/11/2026",
						"purpose": "Recorrido 4x4",
						"passengers": 2,
						"fire_permit": false,
						"fishing_permit": false,
						"job_permit": "Ninguno",
						"is_expired": false
					},
					"car_items": ["Rifle calibre .22 con mira telescópica", "5 Trampas cepo de zorro y guanaco", "Gomera profesional de caza"],
					"should_pass": false,
					"rejection_reasons": ["Portación ilegal de armas de fuego y trampas para caza furtiva"],
					"parcel_impact": {
						"Cerro Chenque y Acantilados": {"damage": 45.0, "tag": "caza"}
					}
				},
				{
					"name": "Ex Empleado Silva",
					"avatar_file": "exEmpleadoSilva.jpg",
					"car_name": "Camión F-350 Rojo",
					"car_color": Color(0.75, 0.2, 0.2),
					"declared_passengers": 2,
					"actual_passengers": 2,
					"dialog_intro": "Hola Chenque, soy Silva, trabajé acá en 2018. Vengo a descargar unos materiales para un galpón.",
					"dialog_interrogate": "¿Permiso de obras o catastro? No hace falta si ya conozco el lugar...",
					"doc": {
						"name": "Rubén Silva",
						"dni": "23.401.999",
						"type": "Pase de Ingreso Diario",
						"date": "28/11/2026",
						"purpose": "Carga y Descarga",
						"passengers": 2,
						"fire_permit": false,
						"fishing_permit": false,
						"job_permit": "Ninguno (Ex Empleado)",
						"is_expired": false
					},
					"car_items": ["10 Chapas de zinc", "Rollos de alambre de púa", "Postes de quebracho para alambrar parcela"],
					"should_pass": false,
					"rejection_reasons": ["Intento de delimitación/usurpación ilegal de tierras protegidas"],
					"parcel_impact": {
						"Humedal y Laguna de Aves": {"damage": 40.0, "tag": "usurpacion"}
					}
				},
				{
					"name": "Claudio Bariloche",
					"avatar_file": "padreDeFamiliaTurista.jpg",
					"car_name": "Chevrolet Spin Blanca",
					"car_color": Color(0.95, 0.95, 0.95),
					"declared_passengers": 4,
					"actual_passengers": 4,
					"dialog_intro": "Hola Don Chenque. Venimos de vacaciones con la familia a conocer el parque y el chalet.",
					"dialog_interrogate": "Llevamos nuestro perrito con correa y libreta de vacunación como exige el reglamento.",
					"doc": {
						"name": "Claudio Bariloche",
						"dni": "30.551.340",
						"type": "Pase de Ingreso Diario",
						"date": "28/11/2026",
						"purpose": "Turismo Familiar Cultural",
						"passengers": 4,
						"fire_permit": false,
						"fishing_permit": false,
						"job_permit": "Ninguno",
						"is_expired": false
					},
					"car_items": ["Guía turística de Comodoro", "Perro con correa y bozal", "Canasta de sándwiches", "Juegos de mesa"],
					"should_pass": true,
					"rejection_reasons": [],
					"parcel_impact": {}
				},
				{
					"name": "Marcos Anormal",
					"avatar_file": "observadorDeAvesAnormal.jpg",
					"car_name": "Furgón Gris Oscuro",
					"car_color": Color(0.35, 0.35, 0.4),
					"declared_passengers": 1,
					"actual_passengers": 1,
					"dialog_intro": "Buenas. Solo voy a observar aves marinas en los nidos de la costa.",
					"dialog_interrogate": "¿Las jaulas? Son para... eh... rescatar pichones que se caigan...",
					"doc": {
						"name": "Marcos Anormal",
						"dni": "37.662.110",
						"type": "Pase de Ingreso Diario",
						"date": "28/11/2026",
						"purpose": "Avistaje de Aves",
						"passengers": 1,
						"fire_permit": false,
						"fishing_permit": false,
						"job_permit": "Ninguno",
						"is_expired": false
					},
					"car_items": ["4 Jaulas trampa para aves", "Redes de captura viva", "Sedantes para fauna"],
					"should_pass": false,
					"rejection_reasons": ["Tráfico y captura ilegal de fauna protegida (jaulas trampa)"],
					"parcel_impact": {
						"Costa y Pingüinera": {"damage": 40.0, "tag": "caza"}
					}
				}
			]
		5:
			return [
				{
					"name": "Falso Inspector Valenzuela",
					"avatar_file": "falsoAgenteDelMinisterio.jpg",
					"car_name": "Ford Ranger Oficial Trucha",
					"car_color": Color(0.85, 0.85, 0.85),
					"declared_passengers": 1,
					"actual_passengers": 1,
					"dialog_intro": "Guardaparque Chenque, vengo del Ministerio Nacional a auditar las cajas fuertes del Chalet Huergo.",
					"dialog_interrogate": "No me haga perder el tiempo, mi credencial es ministerial. ¡Ábrame la barrera ya!",
					"doc": {
						"name": "Inspector Valenzuela",
						"dni": "18.300.999",
						"type": "Credencial Ministerial",
						"date": "10/05/2024", # FECHA VENCIDA HACE 2 AÑOS Y SELLO ADULTERADO
						"purpose": "Auditoría de Fondos y Museo",
						"passengers": 1,
						"fire_permit": false,
						"fishing_permit": false,
						"job_permit": "Credencial Adulterada (Vencida)",
						"is_expired": true
					},
					"car_items": ["Ganzúas y palancas", "Bolsas de arpillera vacías", "Radio inhibidora de señal"],
					"should_pass": false,
					"rejection_reasons": [
						"Credencial ministerial adulterada y VENCIDA",
						"Herramientas de robo y forzado de cerraduras"
					],
					"parcel_impact": {
						"Chalet Histórico": {"damage": 50.0, "tag": "usurpacion"}
					}
				},
				{
					"name": "Técnico Juan Mantenimiento",
					"avatar_file": "tecnicoMantenimiento.jpg",
					"car_name": "Renault Kangoo Amarilla",
					"car_color": Color(0.9, 0.75, 0.2),
					"declared_passengers": 2,
					"actual_passengers": 2,
					"dialog_intro": "Buenas Don Chenque. Venimos de la Cooperativa Eléctrica para reparar el transformador del Chalet.",
					"dialog_interrogate": "Aquí tiene la orden de servicio oficial de la cooperativa y los cascos reglamentarios.",
					"doc": {
						"name": "Juan Mantenimiento",
						"dni": "27.550.119",
						"type": "Orden de Servicio Cooperativa",
						"date": "28/11/2026",
						"purpose": "Reparación Eléctrica Chalet Huergo",
						"passengers": 2,
						"fire_permit": false,
						"fishing_permit": false,
						"job_permit": "Técnico Electricista Oficial",
						"is_expired": false
					},
					"car_items": ["Caja de herramientas aisladas", "Cascos de seguridad", "Tester digital", "Escalera telescópica"],
					"should_pass": true,
					"rejection_reasons": [],
					"parcel_impact": {}
				},
				{
					"name": "Mariano 'Doppelgänger'",
					"avatar_file": "personajeRepetidoConDopelganger.jpg",
					"car_name": "Volkswagen Saveiro Negra",
					"car_color": Color(0.15, 0.15, 0.18),
					"declared_passengers": 2,
					"actual_passengers": 2,
					"dialog_intro": "Hola Chenque. Vengo a pescar y hacer un fueguito en la playa de los pingüinos.",
					"dialog_interrogate": "¿El DNI? Me llamo Nahuel Morales... ¿no me reconocés?",
					"doc": {
						"name": "Nahuel Morales (Suplantación)",
						"dni": "34.892.110", # DNI del Día 1 pero rostro no coincide
						"type": "Pase de Ingreso Diario",
						"date": "28/11/2026",
						"purpose": "Pesca y Fuego",
						"passengers": 2,
						"fire_permit": false, # NO HABILITADO
						"fishing_permit": false, # NO HABILITADO
						"job_permit": "Ninguno",
						"is_expired": false
					},
					"car_items": ["Carbón suelto", "Arpón de buceo ilegal", "Parrilla con grasa"],
					"should_pass": false,
					"rejection_reasons": [
						"Suplantación de identidad (DNI no corresponde al portador)",
						"Portación de arpón ilegal y carbón sin permiso"
					],
					"parcel_impact": {
						"Costa y Pingüinera": {"damage": 30.0, "tag": "pesca_furtiva"},
						"Chalet Histórico": {"damage": 20.0, "tag": "incendio"}
					}
				},
				{
					"name": "Aníbal Trelew (Familia)",
					"avatar_file": "personajeRepetido.jpg",
					"car_name": "Toyota Corolla Gris",
					"car_color": Color(0.65, 0.68, 0.7),
					"declared_passengers": 3,
					"actual_passengers": 3,
					"dialog_intro": "Buenas tardes Mr. Chenque. Venimos a disfrutar la última tarde de otoño en los miradores.",
					"dialog_interrogate": "Todo en regla como siempre, disfrutando el parque de nuestra querida Patagonia.",
					"doc": {
						"name": "Aníbal Trelew",
						"dni": "31.220.884",
						"type": "Pase de Ingreso Diario",
						"date": "28/11/2026",
						"purpose": "Paseo Familiar y Mirador",
						"passengers": 3,
						"fire_permit": false,
						"fishing_permit": false,
						"job_permit": "Ninguno",
						"is_expired": false
					},
					"car_items": ["Termos de mate", "Bizcochitos de grasa", "Mantas de abrigo patagónicas"],
					"should_pass": true,
					"rejection_reasons": [],
					"parcel_impact": {}
				}
			]
		_:
			return []
