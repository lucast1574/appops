# Leasy Ops Mobile Ã¢â‚¬â€ Checklist iOS (para el equipo Mac)

> Este documento describe **lo que ya estÃƒÂ¡ hecho** en el proyecto Flutter y **lo que falta hacer obligatoriamente en una Mac** para tener el app en TestFlight / App Store.
>
> Mientras estÃƒÂ©s leyendo esto: el proyecto compila iOS a nivel de archivos (Podfile, Info.plist, AppDelegate.swift, project.pbxproj, Assets, GoogleService-Info.plist), pero **nunca se ha corrido `pod install` ni `flutter build ios` en una Mac real**. El primer build descubrirÃƒÂ¡ si algÃƒÂºn Pod tiene conflictos.

---

## Ã°Å¸â€œÂ¦ Estado de configuraciÃƒÂ³n (ya hecho)

| Pieza | Estado | Notas |
|---|---|---|
| `ios/` directory tracked en git | Ã¢Å“â€¦ SÃƒÂ­ | Todo el contenido versionado |
| `Podfile` | Ã¢Å“â€¦ | iOS 13.0 mÃƒÂ­nimo, `use_frameworks!`, `use_modular_headers!`, post_install fuerza 13.0 a todos los pods |
| `Info.plist` permission strings | Ã¢Å“â€¦ | Camera, Location When/Always, Photo Library, Photo Add Ã¢â‚¬â€ todas en espaÃƒÂ±ol |
| `Info.plist` UIBackgroundModes | Ã¢Å“â€¦ | `fetch`, `remote-notification`, `location` declarados |
| `Info.plist` URL scheme Google Sign-In | Ã¢Å“â€¦ | `com.googleusercontent.apps.863779943763-...` |
| `Info.plist` orientaciÃƒÂ³n | Ã¢Å“â€¦ | Portrait-only |
| `Info.plist` Scene manifest | Ã¢Å“â€¦ | iOS 13+ Scene/SceneDelegate registrados |
| `AppDelegate.swift` | Ã¢Å“â€¦ | `FirebaseApp.configure()`, `UNUserNotificationCenter.delegate`, APNs Ã¢â€ â€™ FCM token forwarding, MethodChannel `com.leasy.ops/settings` para abrir Settings de ubicaciÃƒÂ³n |
| `SceneDelegate.swift` | Ã¢Å“â€¦ | Subclase de `FlutterSceneDelegate` |
| `Runner-Bridging-Header.h` | Ã¢Å“â€¦ | Importa `GeneratedPluginRegistrant.h` |
| `GoogleService-Info.plist` | Ã¢Å“â€¦ existe localmente, Ã¢ÂÅ’ NO en git por seguridad | Compartir por canal seguro (vault/1Password/Notion). `BUNDLE_ID=com.leasy.ops.leasyOpsMobile`, `PROJECT_ID=opps-app-47b45` |
| `project.pbxproj` bundle id | Ã¢Å“â€¦ | `com.leasy.ops.leasyOpsMobile` |
| `project.pbxproj` deployment target | Ã¢Å“â€¦ | iOS 13.0 |
| `project.pbxproj` signing | Ã¢Å¡Â Ã¯Â¸Â Automatic activado, **DEVELOPMENT_TEAM vacÃƒÂ­o** | El compaÃƒÂ±ero Mac debe asignar el Team de Leasy en Xcode |
| `project.pbxproj` device family | `"1,2"` (iPhone + iPad) | Decidir si dejarlo universal o iPhone-only |
| `Assets.xcassets/AppIcon` | Ã¢Å¡Â Ã¯Â¸Â Placeholder | Correr `dart run flutter_launcher_icons` para usar `assets/icon.png` |
| CÃƒÂ³digo Dart platform-aware | Ã¢Å“â€¦ | `push_service.dart` bifurca iOS/Android. `location_permission_dialog.dart` tiene pasos especÃƒÂ­ficos por plataforma (reciÃƒÂ©n actualizado) |
| `flutter analyze` | Ã¢Å“â€¦ Pasa sin warnings | Validado en Windows |

---

## Ã°Å¸ÂÅ½ Trabajo obligatorio en Mac

### 1. Setup de toolchain (una sola vez)
```bash
# Asumiendo macOS reciente
xcode-select --install                     # Command Line Tools
sudo gem install cocoapods                 # CocoaPods (o brew install cocoapods)
brew install --cask flutter                # o usar el mismo SDK que en Windows
flutter doctor                              # debe mostrar todo Ã¢Å“â€¦ excepto Android si no lo usan
```

### 2. Clonar + setup del proyecto
```bash
git clone git@github.com:leasyauto/appops.git
cd appops
git checkout main
flutter pub get                            # baja deps Dart y regenera ios/Flutter/Generated.xcconfig
```

### 3. Pegar los secretos
Pedir al equipo (canal seguro):
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

Ambos archivos estÃƒÂ¡n en `.gitignore`. Sin ellos Firebase no inicializa.

### 4. CocoaPods
```bash
cd ios
pod install --repo-update                   # baja pods (Firebase, google_sign_in, etc.)
# Si sale error de "deployment target": el Podfile ya fuerza 13.0, no deberÃƒÂ­a pasar
# Si sale problema con M1/M2 Macs:
#   sudo arch -x86_64 gem install ffi
#   arch -x86_64 pod install
```

### 5. Abrir el workspace en Xcode
**Importante:** abrir `ios/Runner.xcworkspace` (NO `Runner.xcodeproj`).

```bash
open ios/Runner.xcworkspace
```

### 6. Signing & Capabilities en Xcode
En el target `Runner` Ã¢â€ â€™ tab **Signing & Capabilities**:

1. **Team:** ya viene preconfigurado como `LA74BXZFC6` en el `project.pbxproj`. Solo verificar que aparezca seleccionado y sin warning rojo. Si el Apple ID del compaÃ±ero del Mac NO pertenece a ese Team, hay que invitarlo desde App Store Connect â†’ Users and Access antes.
2. **Bundle Identifier:** debe mostrar `com.leasy.ops.leasyOpsMobile`. Si Xcode lo cambia, restaurarlo.
3. AÃƒÂ±adir capabilities (botÃƒÂ³n `+ Capability`):
   - **Push Notifications**
   - **Background Modes** Ã¢â€ â€™ marcar:
     - Background fetch
     - Remote notifications
     - Location updates
   - **Sign in with Apple** (solo si en el futuro se requiere para review de Apple Ã¢â‚¬â€ opcional, hoy no se usa)

### 7. APNs Authentication Key en Firebase
**CrÃƒÂ­tico** Ã¢â‚¬â€ sin esto las push notifications iOS NUNCA llegan, aunque el cÃƒÂ³digo estÃƒÂ© perfecto.

1. Apple Developer Portal Ã¢â€ â€™ Keys Ã¢â€ â€™ "+" Ã¢â€ â€™ **APNs Authentication Key** (`.p8`).
2. Descargar el `.p8` (Ã‚Â¡solo se puede descargar una vez!).
3. Anotar el `Key ID` y el `Team ID`.
4. Ir a Firebase Console Ã¢â€ â€™ proyecto `opps-app-47b45` Ã¢â€ â€™ Project Settings Ã¢â€ â€™ Cloud Messaging Ã¢â€ â€™ "Apple app configuration" Ã¢â€ â€™ subir el `.p8` con su Key ID y Team ID.

Verificar: `FirebaseMessaging.instance.getAPNSToken()` debe devolver non-null en device fÃƒÂ­sico.

### 8. App Icon
Una vez que `pod install` corre, generar los ÃƒÂ­conos reales:
```bash
cd ..    # volver a la raÃƒÂ­z del proyecto Flutter
dart run flutter_launcher_icons
```
Esto sobrescribe los placeholders de `ios/Runner/Assets.xcassets/AppIcon.appiconset/` con `assets/icon.png`. Verificar visualmente que se vea bien (esquina superior izquierda al abrir Xcode Ã¢â€ â€™ Assets Ã¢â€ â€™ AppIcon).

### 9. Bundle Identifier en Firebase
Confirmar en Firebase Console que el iOS app del proyecto `opps-app-47b45` tiene:
- Bundle ID: `com.leasy.ops.leasyOpsMobile` (camelCase, no snake_case)
- App ID: `1:985287713026:ios:d6f754f3ebb038f3b0e21b`

Si no coincide, descargar un nuevo `GoogleService-Info.plist`.

### 10. Primer build de prueba (simulador)
```bash
flutter run -d "iPhone 15"   # o cualquier simulador disponible
```
- Verificar que arranca, muestra Splash, pide permiso de notificaciones, pide permiso de ubicaciÃƒÂ³n.
- Verificar que **NO crashea** al pedir permisos (en simulador la ubicaciÃƒÂ³n se simula desde Debug Ã¢â€ â€™ Location).

### 11. Build en device fÃƒÂ­sico
1. Conectar un iPhone con el mismo Apple ID o invitado al Team.
2. En Xcode confiar el certificado en el device (Settings Ã¢â€ â€™ General Ã¢â€ â€™ VPN & Device Management).
3. `flutter run --release -d <device>`.
4. Probar push notifications (mandar desde Firebase Console Ã¢â€ â€™ Cloud Messaging Ã¢â€ â€™ "Send your first message" usando el FCM token que imprime el log de la app).
5. Probar Google Sign-In real.
6. Probar el flujo de location "Siempre" (subir desde "When in use" en Settings).
7. Probar `image_picker` (cÃƒÂ¡mara + galerÃƒÂ­a) con foto real.

### 12. TestFlight
```bash
flutter build ipa --release
# El .ipa queda en build/ios/ipa/
```
Subir con **Transporter.app** (Mac App Store) o `xcrun altool`:
```bash
xcrun altool --upload-app -f build/ios/ipa/leasy_ops_mobile.ipa \
  -t ios -u <apple-id-email> -p <app-specific-password>
```

Luego en App Store Connect Ã¢â€ â€™ Apps Ã¢â€ â€™ Leasy Ops Ã¢â€ â€™ TestFlight Ã¢â€ â€™ asignar testers.

---

## Ã¢Å¡Â Ã¯Â¸Â Cosas que probablemente revienten en el primer build (y cÃƒÂ³mo arreglarlas)

### `pod install` falla con "CocoaPods could not find compatible versions"
Ã¢â€ â€™ Borrar `Podfile.lock`, `Pods/` y `~/Library/Caches/CocoaPods` Ã¢â€ â€™ `pod repo update` Ã¢â€ â€™ `pod install`.

### Error de Swift version
Ã¢â€ â€™ El `project.pbxproj` declara `SWIFT_VERSION = 5.0`. Si algÃƒÂºn pod requiere Swift 5.5+, no deberÃƒÂ­a ser problema en Xcode 14+.

### `Firebase.initializeApp()` falla en runtime
Ã¢â€ â€™ Probablemente falta `GoogleService-Info.plist` o no estÃƒÂ¡ agregado al target en Xcode (debe aparecer en el group `Runner` con check para target `Runner`).

### Push token no llega (`apnsToken` es nil)
Ã¢â€ â€™ Capability "Push Notifications" no activada en Xcode, o APNs Auth Key no subida a Firebase.

### Build falla con "Provisioning profile doesn't include the aps-environment entitlement"
Ã¢â€ â€™ Falta activar la capability "Push Notifications" Ã¢â‚¬â€ Xcode regenera el provisioning solo si la capability estÃƒÂ¡ marcada.

### `image_picker` crashea al tomar foto en iOS
Ã¢â€ â€™ AlgÃƒÂºn `NSPhotoLibraryUsageDescription` mal escrito. Ya estÃƒÂ¡n en el `Info.plist`, deberÃƒÂ­a estar bien.

### Geolocator no pide "Always"
Ã¢â€ â€™ En iOS, "Always" solo se ofrece DESPUÃƒâ€°S de aceptar "When in use" y de que la app use ubicaciÃƒÂ³n en background. El flow del `permission_gate_page` ya maneja esto enviando al usuario a Settings.

---

## Ã°Å¸â€œâ€¹ Resumen ultra-corto

**Para tu compaÃƒÂ±ero Mac:**

1. Clonar repo, `flutter pub get`.
2. Pedir `GoogleService-Info.plist` y `google-services.json` por canal seguro y pegarlos.
3. `cd ios && pod install`.
4. Abrir `ios/Runner.xcworkspace` en Xcode.
5. Signing & Capabilities Ã¢â€ â€™ asignar Team Leasy + activar Push Notifications + Background Modes (3 modos).
6. Subir APNs `.p8` a Firebase (proyecto `opps-app-47b45`).
7. `dart run flutter_launcher_icons` para ÃƒÂ­conos.
8. `flutter run` en simulador Ã¢â€ â€™ device Ã¢â€ â€™ `flutter build ipa --release` Ã¢â€ â€™ TestFlight.

Cualquier duda: el cÃƒÂ³digo Flutter estÃƒÂ¡ bien, solo es trabajo de configuraciÃƒÂ³n nativa.