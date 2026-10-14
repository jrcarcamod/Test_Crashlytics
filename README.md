# Prueba de Firebase Crashlytics en iOS

Aplicación Flutter **solo para iOS** con una pantalla en español y el botón **Generar crash**. El botón provoca un cierre nativo real mediante `FirebaseCrashlytics.instance.crash()`. Antes del cierre se agrega `test_type=native_crash` y un log para identificar la prueba.

## Firebase configurado

- Proyecto: `demos-b1781`.
- App iOS: `1:115545856173:ios:70038e6588e4b3f00a0e24`.
- Bundle ID: `com.digitalreef.DigitalReefDevApp` en Debug, Profile y Release.
- Configuración existente: `ios/Runner/GoogleService-Info.plist`, incluida en los recursos de Runner.
- [Consola de Crashlytics](https://console.firebase.google.com/project/demos-b1781/crashlytics).

La app inicializa Firebase desde el plist nativo y habilita la recopilación de Crashlytics, incluso en Debug. También registra errores fatales del framework Flutter y errores asíncronos sin capturar. Si la inicialización falla, muestra **Reintentar** y mantiene el crash deshabilitado.

El archivo `GoogleService-Info.plist` se conserva localmente y está excluido de Git. Al crear otro checkout, copia el archivo proporcionado antes de compilar:

```sh
cp /Users/josecarcamo/Downloads/GoogleService-Info-2.plist ios/Runner/GoogleService-Info.plist
```

## Requisitos y ejecución

Se necesita macOS, Flutter, Xcode con herramientas de línea de comandos y CocoaPods. El proyecto requiere **iOS 15 o posterior** por las dependencias Firebase instaladas. `pubspec.lock` y `ios/Podfile.lock` fijan las versiones resueltas. No es necesario instalar Firebase CLI ni FlutterFire CLI para esta configuración. Con Flutter 3.38 y Xcode 27, Debug compila el simulador para la arquitectura del Mac mediante `NATIVE_ARCH_ACTUAL`, evitando [el problema de verificación multi-arquitectura de Flutter](https://github.com/flutter/flutter/issues/188461). Las compilaciones de iPhone físico no usan ese ajuste. Runner adopta el ciclo de vida `UIScene` y registra los plugins al crear el motor Flutter, necesarios para iniciar con Xcode 27. [Migración oficial de Flutter](https://docs.flutter.dev/release/breaking-changes/uiscenedelegate).

```sh
flutter pub get
flutter build ios --simulator --debug
open ios/Runner.xcworkspace
```

Abre **Runner.xcworkspace** en Xcode. Para un iPhone físico, selecciona el target **Runner → Signing & Capabilities → Team** y elige tu equipo. El identificador debe seguir coincidiendo con el plist. La firma y el perfil de aprovisionamiento deben permitir ese Bundle ID. Si tu equipo necesita un identificador distinto, registra esa app iOS en Firebase y reemplaza su plist antes de cambiar el identificador.

Para probar en un **iPhone físico**, instala una compilación **Release**:

```sh
flutter run --release -d <iPhone>
```

Desde Xcode, selecciona **Product → Scheme → Edit Scheme → Run → Info → Build Configuration → Release**, elige el iPhone y ejecuta. Luego termina la sesión y abre la app desde su icono. Flutter Debug en un iPhone con iOS 14 o posterior necesita las herramientas de desarrollo para iniciar; por eso la prueba del crash y el reinicio desde el icono requieren Release (o Profile). [Referencia oficial de Flutter](https://api.flutter.dev/flutter/services/RestorationManager-class.html).

Para un **simulador**, usa `flutter run --debug -d <simulador>` o el esquema Debug de Xcode. Debug sí permite el reinicio desde el icono en el simulador; Release está destinado a dispositivos físicos.

## Generar y ver el primer crash

1. Instala **Release en el iPhone físico** o **Debug en el simulador**, siguiendo las instrucciones anteriores. Abre la app con internet y espera **Crashlytics listo**.
2. Si la ejecutaste desde Xcode, presiona **Stop**; si usaste `flutter run --release` en el iPhone o `flutter run --debug` en el simulador, termina esa sesión. Abre nuevamente la app desde su icono, sin depurador conectado. Firebase recomienda desconectar el depurador porque este intercepta los fallos.
3. Presiona **Generar crash**. La app se cerrará intencionalmente.
4. Abre nuevamente **la misma instalación** desde su icono y déjala abierta con internet. Crashlytics envía el reporte pendiente al iniciar otra vez. No desinstales la app entre el fallo y ese reinicio.
5. Entra a la consola de Crashlytics del proyecto `demos-b1781`, selecciona la app `com.digitalreef.DigitalReefDevApp` y espera unos minutos. Busca el fallo nativo y su clave `test_type=native_crash`.

La compilación y los tests locales no confirman que un reporte ya aparezca en la consola; eso requiere esta prueba y acceso al proyecto Firebase.

## Símbolos y problemas frecuentes

Runner genera dSYM en todas las configuraciones. La última fase **Crashlytics Upload Symbols** ejecuta el script oficial de CocoaPods `${PODS_ROOT}/FirebaseCrashlytics/run`, con las rutas de entrada del dSYM, el ejecutable y el plist compilado. El hook `post_integrate` mantiene esa fase al final después de instalar los Pods.

Si el reporte no aparece después de unos cinco minutos, confirma que reiniciaste la misma instalación, que no había depurador y que hay conexión. En Xcode puedes añadir temporalmente `-FIRDebugEnabled` en **Product → Scheme → Edit Scheme → Run → Arguments Passed On Launch** y revisar los mensajes de Crashlytics al reiniciar. Para reproducir el crash, vuelve a lanzar desde el icono sin depurador.

Si Firebase muestra **Missing dSYM**, revisa la fase de símbolos y el dSYM de la compilación exacta que se cerró. Puedes subirlo manualmente:

```sh
ios/Pods/FirebaseCrashlytics/upload-symbols \
  -gsp ios/Runner/GoogleService-Info.plist \
  -p ios /ruta/al/Runner.app.dSYM
```

También puedes cargar el dSYM comprimido en la pestaña **dSYMs** de Crashlytics. Si falla la preparación del crash, la pantalla muestra el error y permite intentar de nuevo; los detalles quedan en el log de desarrollo.

## Verificación local

```sh
dart format lib test
flutter analyze
flutter test
python3 -B -m unittest discover -s test/ios -p 'test_*.py'
flutter build ios --simulator --debug
flutter build ios --release --no-codesign
```

La última orden verifica la compilación de iPhone sin firma; para instalarla en un dispositivo debes compilar con firma y un equipo válido.

Dos verificaciones de configuración nativa previenen la regresión de inicio de iOS 27 (escena y registro de plugins). Los tests de widgets usan un servicio falso: verifican carga, habilitación, una única llamada de crash, protección frente a pulsaciones rápidas y recuperación de errores. **No generan crashes reales ni envían reportes a Firebase.**

Documentación oficial: [Crashlytics para Flutter](https://firebase.google.com/docs/crashlytics/flutter/get-started), [probar Crashlytics en Apple](https://firebase.google.com/docs/crashlytics/ios/test-implementation) y [dSYM en Apple](https://firebase.google.com/docs/crashlytics/ios/get-deobfuscated-reports).
