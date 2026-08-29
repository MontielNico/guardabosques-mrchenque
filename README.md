# 🌲 Guarda-Bosques: Patagonia (Parque Chalet Huergo)

Prototipo de videojuego 2D estilo **Papers, Please** desarrollado en **Godot Engine 4** ambientado en el histórico **Chalet Huergo** y el **Cerro Chenque** (Comodoro Rivadavia, Chubut, Patagonia Argentina).

---

## 🎮 Contexto y Jugabilidad

Encarnas a **Mr. Chenque**, el guardaparques responsable del puesto de control durante **5 días consecutivos**.
Tu misión es controlar el acceso de los visitantes, comprobar documentación y pertenencias, prevenir incendios, tala, usurpaciones y caza furtiva, al tiempo que mantienes el fondo familiar para subsistir.

---

## 🖥️ Arquitectura de Vistas (5 Ventanas Funcionales)

El juego se organiza en una interfaz estructurada de **5 ventanas** (3 superiores y 2 inferiores):

### 📋 Vista 1 - Vista Principal:
1. **1° Ventana Superior Izquierda (Oficina & Exterior):**
   - Vista por la ventana de la garita hacia el camino de entrada, mostrando el vehículo aproximándose y el fondo del parque con clima y viento patagónico.
2. **2° Ventana Superior Centro (Visitante):**
   - Retrato/Fotografía del visitante cargada desde `/public`, nombre y diálogo de presentación.
3. **3° Ventana Superior Derecha (Mapa de 5 Parcelas):**
   - Mapa general del Parque Nacional Chalet Huergo dividido en **5 parcelas** (*Chalet Histórico*, *Bosque de Lengas*, *Costa y Pingüinera*, *Cerro Chenque y Acantilados*, *Humedal y Laguna de Aves*).
   - Refleja en tiempo real la salud y el impacto visual si dejamos pasar infractores (árboles talados 🪓, fuego/cenizas 🔥, construcciones/usurpación 🏗️, animales cazados 🎯, pesca ilegal 🚫).
4. **4° Ventana Inferior Izquierda (Escritorio del Guardaparques):**
   - Documentación del visitante sobre la mesa: Identificación / Pase Diario, Permiso de Fogón/Fuego, Permiso de Pesca Provincial y Permiso de Oficio.
5. **5° Ventana Inferior Derecha (Panel de Decisiones):**
   - Botones de control: 🟢 **AUTORIZAR**, 🔴 **DENEGAR**, 🔍 **INSPECCIONAR VEHÍCULO** y 📖 **LEER REGLAS DEL PARQUE**.

---

### 🔍 Vista 2 - Vista de Investigación:
Se activa al hacer clic en **INSPECCIONAR VEHÍCULO**:
- **Ventana Superior Derecha:** El mapa se oculta y se visualiza el **Baúl Abierto del Auto** con la lista de pertenencias (carbón, redes, motosierras, armas, etc.) y conteo real de pasajeros vs declarados.
- **Ventana Superior Centro:** Habilita el botón **💬 Interrogar al visitante** para obtener su coartada o diálogo de interrogatorio.
- **Ventana Inferior Derecha:** El botón inspeccionar cambia para permitir **Autorizar**, **Denegar** o **Volver al Mapa**.

---

## 🚀 Cómo Ejecutar el Juego

### Opción 1: Desde Godot Editor
1. Abre **Godot Engine 4** (`Godot_v4.7.2-stable_win64.exe`).
2. Importa el archivo `project.godot` dentro de `Documents/guarda-bosques-patagonia`.
3. Presiona **F5** o el botón de Play ▶️ arriba a la derecha.

### Opción 2: Desde la Terminal / PowerShell
```powershell
& "C:\Users\bruno\Desktop\Godot_v4.7.2-stable_win64_console.exe" --path "C:\Users\bruno\Documents\guarda-bosques-patagonia"
```
