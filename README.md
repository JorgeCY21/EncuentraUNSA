# Encuentra UNSA

Aplicación académica de objetos perdidos y encontrados. Laboratorio 04, Plataformas Emergentes.

## Abrir y ejecutar

1. Descomprime el ZIP en una carpeta que puedas escribir.
2. En VS Code, usa Archivo > Abrir carpeta y selecciona encuentra_unsa (la carpeta con pubspec.yaml).
3. Abre Terminal > Nuevo terminal.
4. Ejecuta `flutter pub get` y espera a que termine.
5. Ejecuta `flutter run -d chrome` para abrir la aplicación en Chrome.

También puedes elegir Chrome en la barra de dispositivos de VS Code y presionar F5.
Si flutter no se reconoce, reinicia VS Code y comprueba que flutter/bin esté en PATH.
Proyecto verificado con Flutter 3.47.7 y Dart 3.13.5.

## Demostración para la exposición

1. En Explorar, busca "audifonos": la búsqueda ignora tildes.
2. Alterna Perdidos y Encontrados y prueba una categoría. Restablece Todos.
3. Abre Audífonos inalámbricos y pulsa Copiar contacto. No se envía ningún mensaje.
4. Vuelve al inicio, selecciona Publicar un aviso e intenta guardar sin datos: aparecen validaciones.
5. Registra "Mochila azul", lugar "Biblioteca central", una descripción y "demo@example.com".
6. Añade una foto opcional desde el selector si quieres demostrarlo. Máximo 700000 bytes tras procesarla.
7. Guarda. Abre Mis publicaciones, selecciona el aviso y edita la descripción.
8. En el detalle, marca el aviso como resuelto y confirma. Ya no se muestra en Explorar.
9. Activa Incluir avisos resueltos en Mis publicaciones. Abre el detalle y reabre el aviso.
10. Recarga la aplicación para comprobar el guardado local en tu navegador.

Los ejemplos iniciales son ficticios. Los registros con mine=true representan al usuario de demostración.
No hay cuentas reales, chat, servidor ni sincronización. Borrar los datos del navegador elimina los avisos.
No es un servicio oficial de la UNSA.

## Código y componentes

- lib/main.dart: inicialización y tema Material 3.
- lib/store.dart: Notice, búsqueda, estado y persistencia con shared_preferences.
- lib/screens.dart: cinco vistas y componentes reutilizables.
- test/app_test.dart: tres pruebas de comportamiento y renderizado.
- test/captures: imágenes de referencia creadas desde widgets, no fotografías de un dispositivo.
- test/fonts: fuentes de pruebas y sus licencias.

Los comentarios C01 y C02 explican los cambios de persistencia y layout.
El informe Word describe el diseño y el desarrollo de las interfaces. El código completo y las pruebas están en este repositorio.

## Verificación

```text
flutter analyze
flutter test
flutter build web --release
```

Para regenerar imágenes tras cambios intencionales: `flutter test --update-goldens`.
Las imágenes de referencia pueden variar por versión de Flutter o plataforma.
No actualices las referencias para ocultar un fallo de comportamiento.

La compilación web y tres pruebas se completaron durante la preparación.
Las pruebas de almacenamiento utilizan el sustituto de SharedPreferences del framework.
El selector de fotos, portapapeles y Android necesitan una comprobación manual en el equipo o dispositivo objetivo.

## Android

Configura Android Studio, el SDK y un emulador o celular con depuración USB.
Ejecuta `flutter doctor` y resuelve los avisos de Android.
Conecta el dispositivo y ejecuta `flutter run`.
Para generar un APK de demostración: `flutter build apk --debug`.
No se adjunta un APK ni se afirma que haya sido probado en Android.

## Fuentes

- https://docs.flutter.dev/ui/layout
- https://docs.flutter.dev/cookbook/forms/validation
- https://api.flutter.dev/flutter/widgets/LayoutBuilder-class.html
- https://pub.dev/packages/shared_preferences
- https://pub.dev/packages/image_picker
- https://docs.flutter.dev/cookbook/testing/widget/introduction

