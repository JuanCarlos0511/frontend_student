# Uni Social Student

📱 **Red Social Privada Universitaria - App del Estudiante**

Aplicación móvil desarrollada en Flutter orientada a conectar a todos los estudiantes universitarios. Esta aplicación incluye características esenciales de redes sociales enfocadas en fomentar la interacción dentro del campus.

## 🚀 Características (Features)
La arquitectura del proyecto está organizada por características (`/lib/features`), e incluye:
- **Autenticación:** Inicio de sesión (`auth_login`) y registro (`auth_registration`).
- **Feed de Noticias:** Publicaciones y actualizaciones compartidas (`feed`).
- **Comunidades:** Espacios para grupos estudiantiles (`communities`).
- **Mercado (Market):** Intercambio y venta de artículos dentro de la universidad (`market`).
- **Chat en tiempo real:** Comunicación directa mediante WebView/Socket.io (`chat`).
- **Rutas de Bus:** Seguimiento de rutas de autobús y localización (`bus`).
- **Perfil:** Perfil personal del estudiante (`profile`).
- **Reportes:** Sistema de reporte de usuarios y moderación (`reports`, `moderator`).

## 🛠 Tecnologías y Dependencias
- [Flutter](https://flutter.dev/) (Framework principal)
- **State Management:** Provider (`provider`)
- **HTTP / Red:** Dio (`dio`), Socket.io (`socket_io_client`)
- **Mapa y Geolocalización:** Flutter Map (`flutter_map`), LatLong2 (`latlong2`), Geolocator (`geolocator`)
- **UI / Archivos:** Google Fonts, Cupertino Icons, Cached Network Image, Filer Picker, Image Picker

## 📁 Estructura del Proyecto
El proyecto sigue una arquitectura limpia orientada a Features, separando claramente la vista de la lógica.

```bash
lib/
 ├── core/         # Configuraciones de red (Dio), rutas (AppRoutes) y temas.
 ├── features/     # Módulos principales de la aplicación con su propia Data, Logic, y Presentation.
 ├── shared/       # Widgets reutilizables, inputs, botones, search bars.
 └── main.dart     # Punto de entrada de la app.
```

## ⚙ Configuración e Instalación

1. **Clonar este repositorio**
   ```bash
   git clone https://github.com/ismaelhda05/frontend_.git
   ```
2. **Obtener las dependencias**
   ```bash
   flutter pub get
   ```
3. **Ejecutar el proyecto**
   ```bash
   flutter run
   ```

## 🤝 Próximos pasos y contribución
Si deseas contribuir o integrar este proyecto en tu repo principal, asegúrate de mantener actualizadas las directrices del proyecto y realizar un _Pull Request_.

