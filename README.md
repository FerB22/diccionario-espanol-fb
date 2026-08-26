# 📖 Diccionario de la Lengua Española (Diccionario Español FB)

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![SQLite](https://img.shields.io/badge/SQLite-FTS5-003B57?style=for-the-badge&logo=sqlite&logoColor=white)](https://sqlite.org)
[![License](https://img.shields.io/badge/Licencia-CC%20BY--SA%203.0-lightgrey?style=for-the-badge)](https://creativecommons.org/licenses/by-sa/3.0/)

Una aplicación móvil moderna, elegante y 100% offline del Diccionario de la Lengua Española desarrollada en **Flutter**, con tipografía y diseño editorial clásico inspirado en las ediciones de la RAE, motor de búsqueda SQLite FTS5 ultrarrápido y pronunciación por voz (TTS).

---

## ✨ Características Principales

- **⚡ 100% Offline:** Base de datos SQLite embebida con más de 800.000 entradas, acepciones, sinónimos, antónimos y locuciones sin necesidad de conexión a internet.
- **🔍 Múltiples Modos de Búsqueda:**
  - **Palabra:** Búsqueda predictiva e incremental instantánea.
  - **Expresiones y Locuciones:** Búsqueda en más de 21.000 frases hechas y giros idiomáticos.
  - **Exacta:** Coincidencia estricta de lemas.
  - **Comienza por... / Termina en... / Contiene...**
  - **Anagramas:** Encuentra todas las palabras formadas con las mismas letras.
  - **Aleatoria:** Descubre nuevas palabras al azar con un solo toque.
- **📚 Navegación Hipertextual Completa:**
  - Toca cualquier palabra dentro de las definiciones, ejemplos o dudas frecuentes para saltar directamente a su significado.
  - Barra de navegación inferior con historial de navegación interno (estilo navegador con botones Atrás y Adelante).
- **🗣️ Pronunciación y Fonética:**
  - Transcripción fonética internacional (IPA).
  - Pronunciación por voz mediante Text-to-Speech (`flutter_tts`) con animación de audio reactiva.
- **🌱 Etimología y Dudas Frecuentes:**
  - Origen etimológico en tarjetas de estilo editorial clásico.
  - Bloque de «Dudas Frecuentes» y parónimos para evitar confusiones léxicas.
- **⭐ Favoritos e Historial:** Guarda tus palabras preferidas y consulta búsquedas recientes en cualquier momento.
- **✨ Palabra del Día:** Descubre un término destacado que se mantiene durante toda la jornada.
- **🌓 Modo Oscuro & Ajuste de Tamaño de Fuente:** Soporte completo de temas Claro/Oscuro y escalado dinámico de tipografía (Playfair Display + Serif clásica).

---

## 🏛️ Arquitectura del Proyecto

El código fuente sigue una arquitectura modular y desacoplada:

```
diccionario_app/
├── assets/
│   ├── diccionario.db             # Base de datos SQLite optimizada con índices y FTS5
│   ├── fonts/                     # Tipografías Playfair Display
│   └── images/                    # Recursos gráficos
├── lib/
│   ├── data/
│   │   └── database_helper.dart   # Singleton de acceso a SQLite y queries de búsqueda
│   ├── models/
│   │   ├── search_result.dart     # DTO ligero para listas y resultados
│   │   └── word.dart              # Modelo de lema, sentidos y categorías
│   ├── providers/
│   │   └── app_provider.dart      # Gestión de preferencias (Modo oscuro, tamaño de fuente)
│   ├── screens/
│   │   ├── favorites_screen.dart  # Pantalla de favoritos
│   │   ├── help_screen.dart       # Guía de uso y ayuda
│   │   ├── history_screen.dart    # Historial de consultas
│   │   ├── home_screen.dart       # Pantalla principal y palabra del día
│   │   ├── search_results_screen.dart # Búsqueda en tiempo real con debounce
│   │   ├── splash_screen.dart     # Pantalla de inicio
│   │   └── word_detail_screen.dart# Orquestador del detalle de palabra
│   ├── services/
│   │   └── tts_service.dart       # Servicio de síntesis de voz (TTS)
│   ├── theme/
│   │   └── app_theme.dart         # Temas claro y oscuro editorial
│   ├── utils/
│   │   └── lexical_helpers.dart   # Traducción de etiquetas, abreviaturas POS y lemas
│   └── widgets/
│       ├── app_drawer.dart        # Menú lateral con configuración
│       ├── clickable_span_builder.dart # Constructor seguro de hipervínculos
│       └── detail/                # Componentes modulares del visor de detalle
│           ├── etymology_card.dart
│           ├── history_bottom_bar.dart
│           ├── paronimo_card.dart
│           ├── senses_section.dart
│           ├── synonyms_antonyms_section.dart
│           └── word_detail_header.dart
└── pubspec.yaml
```

---

## 🚀 Requisitos e Instalación

### Prerrequisitos
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`^3.13.1` o superior)
- Dart SDK (`^3.13.1` o superior)
- Android Studio / VS Code con extensiones de Flutter y Dart
- Dispositivo Android con depuración USB activada o Emulador

### Pasos para compilar y ejecutar

1. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/FerB22/diccionario-espanol-fb.git
   cd diccionario-espanol-fb
   ```

2. **Instalar dependencias de Flutter:**
   ```bash
   flutter pub get
   ```

3. **Ejecutar en tu dispositivo o emulador:**
   ```bash
   flutter run
   ```

4. **Generar APK de producción:**
   ```bash
   flutter build apk --release
   ```

---

## 📦 Dependencias Principales

- [`sqflite`](https://pub.dev/packages/sqflite): Motor de base de datos SQLite embebida.
- [`provider`](https://pub.dev/packages/provider): Manejo de estado reactivo para temas y preferencias.
- [`shared_preferences`](https://pub.dev/packages/shared_preferences): Persistencia local de ajustes y palabra del día.
- [`flutter_tts`](https://pub.dev/packages/flutter_tts): Pronunciación por síntesis de voz.
- [`share_plus`](https://pub.dev/packages/share_plus): Compartir definiciones fácilmente.

---

## 📄 Licencia y Atribución

Los datos léxicos provienen de las extracciones estructuradas del [Wikcionario en español](https://es.wiktionary.org/) (Wiktionary), distribuidos bajo la licencia [Creative Commons Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0)](https://creativecommons.org/licenses/by-sa/3.0/).

