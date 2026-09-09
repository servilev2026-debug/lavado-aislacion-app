# Lavado de Aislación — compilación en la nube

Este proyecto está preparado para compilarse como APK sin instalar Flutter ni Android Studio en el computador.

## Opción recomendada: GitHub Actions

1. Crea un repositorio en GitHub.
2. Sube todo el contenido de esta carpeta conservando la estructura.
3. El workflow `.github/workflows/build-apk.yml` compilará automáticamente el APK.
4. En GitHub entra a **Actions**, abre la ejecución y descarga el artefacto `lavado-aislacion-apk`.

## Importante
- Esta versión es una reconstrucción funcional basada en el proyecto que veníamos trabajando.
- No contiene Firebase porque no se disponía de `firebase_options.dart`.
- Para publicación en Google Play posteriormente habrá que configurar firma de producción.
