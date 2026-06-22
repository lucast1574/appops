# Leasy Ops Mobile â€” Checklist iOS (para el equipo Mac)

> Este documento describe **lo que ya estÃ¡ hecho** en el proyecto Flutter y **lo que falta hacer obligatoriamente en una Mac** para tener el app en TestFlight / App Store.
>
> Mientras estÃ©s leyendo esto: el proyecto compila iOS a nivel de archivos (Podfile, Info.plist, AppDelegate.swift, project.pbxproj, Assets, GoogleService-Info.plist), pero **nunca se ha corrido `pod install` ni `flutter build ios` en una Mac real**. El primer build descubrirÃ¡ si algÃºn Pod tiene conflictos.

---

## ðŸ“¦ Estado de configuraciÃ³n (ya hecho)

| Pieza | Estado | Notas |
|---|---|---|
| `ios/` directory tracked en git | âœ… SÃ­ | Todo el contenido versionado |
| `Podfile` | âœ… | iOS 13.0 mÃ­nimo, `use_frameworks!`, `use_modular_headers!`, post_install fuerza 13.0 a todos los pods |
| `Info.plist` permission strings | âœ… | Camera, Location When/Always, Photo Library, Photo Add â€” todas en espaÃ±ol |
| `Info.plist` UIBackgroundModes | âœ… | `fetch`, `remote-notification`, `location` declarados |
| `Info.plist` URL scheme Google Sign-In | âœ… | `com.googleusercontent.apps.863779943763-...` |
| `Info.plist` orientaciÃ³n | âœ… | Portrait-only |
| `Info.plist` Scene manifest | âœ… | iOS 13+ Scene/SceneDelegate registrados |
| `AppDelegate.swift` | âœ… | `FirebaseApp.configure()`, `UNUserNotificationCenter.delegate`, APNs â†’ FCM token forwarding, MethodChannel `com.leasy.ops/settings` para abrir Settings de ubicaciÃ³n |
| `SceneDelegate.swift` | âœ… | Subclase de `FlutterSceneDelegate` |
| `Runner-Bridging-Header.h` | âœ… | Importa `GeneratedPluginRegistrant.h` |
| `GoogleService-Info.plist` | âœ… existe localmente, âŒ NO en git por seguridad | Compartir por canal seguro (vault/1Password/Notion). `BUNDLE_ID=com.leasy.ops.leasyOpsMobile`, `PROJECT_ID=opps-app-47b45` |
| `project.pbxproj` bundle id | âœ… | `com.leasy.ops.leasyOpsMobile` |
| `project.pbxproj` deployment target | âœ… | iOS 13.0 |
| `project.pbxproj` signing | âš ï¸ Automatic activado, **DEVELOPMENT_TEAM vacÃ­o** | El compaÃ±ero Mac debe asignar el Team de Leasy en Xcode |
| `project.pbxproj` device family | `"1,2"` (iPhone + iPad) | Decidir si dejarlo universal o iPhone-only |
| `Assets.xcassets/AppIcon` | âš ï¸ Placeholder | Correr `dart run flutter_launcher_icons` para usar `assets/icon.png` |
| CÃ³digo Dart platform-aware | âœ… | `push_service.dart` bifurca iOS/Android. `location_permission_dialog.dart` tiene pasos especÃ­ficos por plataforma (reciÃ©n actualizado) |
| `flutter analyze` | âœ… Pasa sin warnings | Validado en Windows |

---

## ðŸŽ Trabajo obligatorio en Mac

### 1. Setup de toolchain (una sola vez)
```bash
# Asumiendo macOS reciente
xcode-select --install                     # Command Line Tools
sudo gem install cocoapods                 # CocoaPods (o brew install cocoapods)
brew install --cask flutter                # o usar el mismo SDK que en Windows
flutter doctor                              # debe mostrar todo âœ… excepto Android si no lo usan
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

Ambos archivos estÃ¡n en `.gitignore`. Sin ellos Firebase no inicializa.

### 4. CocoaPods
```bash
cd ios
pod install --repo-update                   # baja pods (Firebase, google_sign_in, etc.)
# Si sale error de "deployment target": el Podfile ya fuerza 13.0, no deberÃ­a pasar
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
En el target `Runner` â†’ tab **Signing & Capabilities**:

1. **Team:** ya viene preconfigurado como `LA74BXZFC6` en el `project.pbxproj`. Solo verificar que aparezca seleccionado y sin warning rojo. Si el Apple ID del compañero del Mac NO pertenece a ese Team, hay que invitarlo desde App Store Connect → Users and Access antes.
2. **Bundle Identifier:** debe mostrar `com.leasy.ops.leasyOpsMobile`. Si Xcode lo cambia, restaurarlo.
3. AÃ±adir capabilities (botÃ³n `+ Capability`):
   - **Push Notifications**
   - **Background Modes** â†’ marcar:
     - Background fetch
     - Remote notifications
     - Location updates
   - **Sign in with Apple** (solo si en el futuro se requiere para review de Apple â€” opcional, hoy no se usa)

### 7. APNs Authentication Key en Firebase
**CrÃ­tico** â€” sin esto las push notifications iOS NUNCA llegan, aunque el cÃ³digo estÃ© perfecto.

1. Apple Developer Portal â†’ Keys â†’ "+" â†’ **APNs Authentication Key** (`.p8`).
2. Descargar el `.p8` (Â¡solo se puede descargar una vez!).
3. Anotar el `Key ID` y el `Team ID`.
4. Ir a Firebase Console â†’ proyecto `opps-app-47b45` â†’ Project Settings â†’ Cloud Messaging â†’ "Apple app configuration" â†’ subir el `.p8` con su Key ID y Team ID.

Verificar: `FirebaseMessaging.instance.getAPNSToken()` debe devolver non-null en device fÃ­sico.

### 8. App Icon
Una vez que `pod install` corre, generar los Ã­conos reales:
```bash
cd ..    # volver a la raÃ­z del proyecto Flutter
dart run flutter_launcher_icons
```
Esto sobrescribe los placeholders de `ios/Runner/Assets.xcassets/AppIcon.appiconset/` con `assets/icon.png`. Verificar visualmente que se vea bien (esquina superior izquierda al abrir Xcode â†’ Assets â†’ AppIcon).

### 9. Bundle Identifier en Firebase
Confirmar en Firebase Console que el iOS app del proyecto `opps-app-47b45` tiene:
- Bundle ID: `com.leasy.ops.leasyOpsMobile` (camelCase, no snake_case)
- App ID: `1:985287713026:ios:d6f754f3ebb038f3b0e21b`

Si no coincide, descargar un nuevo `GoogleService-Info.plist`.

### 10. Primer build de prueba (simulador)
```bash
flutter run -d "iPhone 15"   # o cualquier simulador disponible
```
- Verificar que arranca, muestra Splash, pide permiso de notificaciones, pide permiso de ubicaciÃ³n.
- Verificar que **NO crashea** al pedir permisos (en simulador la ubicaciÃ³n se simula desde Debug â†’ Location).

### 11. Build en device fÃ­sico
1. Conectar un iPhone con el mismo Apple ID o invitado al Team.
2. En Xcode confiar el certificado en el device (Settings â†’ General â†’ VPN & Device Management).
3. `flutter run --release -d <device>`.
4. Probar push notifications (mandar desde Firebase Console â†’ Cloud Messaging â†’ "Send your first message" usando el FCM token que imprime el log de la app).
5. Probar Google Sign-In real.
6. Probar el flujo de location "Siempre" (subir desde "When in use" en Settings).
7. Probar `image_picker` (cÃ¡mara + galerÃ­a) con foto real.

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

Luego en App Store Connect â†’ Apps â†’ Leasy Ops â†’ TestFlight â†’ asignar testers.

---

## âš ï¸ Cosas que probablemente revienten en el primer build (y cÃ³mo arreglarlas)

### `pod install` falla con "CocoaPods could not find compatible versions"
â†’ Borrar `Podfile.lock`, `Pods/` y `~/Library/Caches/CocoaPods` â†’ `pod repo update` â†’ `pod install`.

### Error de Swift version
â†’ El `project.pbxproj` declara `SWIFT_VERSION = 5.0`. Si algÃºn pod requiere Swift 5.5+, no deberÃ­a ser problema en Xcode 14+.

### `Firebase.initializeApp()` falla en runtime
â†’ Probablemente falta `GoogleService-Info.plist` o no estÃ¡ agregado al target en Xcode (debe aparecer en el group `Runner` con check para target `Runner`).

### Push token no llega (`apnsToken` es nil)
â†’ Capability "Push Notifications" no activada en Xcode, o APNs Auth Key no subida a Firebase.

### Build falla con "Provisioning profile doesn't include the aps-environment entitlement"
â†’ Falta activar la capability "Push Notifications" â€” Xcode regenera el provisioning solo si la capability estÃ¡ marcada.

### `image_picker` crashea al tomar foto en iOS
â†’ AlgÃºn `NSPhotoLibraryUsageDescription` mal escrito. Ya estÃ¡n en el `Info.plist`, deberÃ­a estar bien.

### Geolocator no pide "Always"
â†’ En iOS, "Always" solo se ofrece DESPUÃ‰S de aceptar "When in use" y de que la app use ubicaciÃ³n en background. El flow del `permission_gate_page` ya maneja esto enviando al usuario a Settings.

---

## ðŸ“‹ Resumen ultra-corto

**Para tu compaÃ±ero Mac:**

1. Clonar repo, `flutter pub get`.
2. Pedir `GoogleService-Info.plist` y `google-services.json` por canal seguro y pegarlos.
3. `cd ios && pod install`.
4. Abrir `ios/Runner.xcworkspace` en Xcode.
5. Signing & Capabilities â†’ asignar Team Leasy + activar Push Notifications + Background Modes (3 modos).
6. Subir APNs `.p8` a Firebase (proyecto `opps-app-47b45`).
7. `dart run flutter_launcher_icons` para Ã­conos.
8. `flutter run` en simulador â†’ device â†’ `flutter build ipa --release` â†’ TestFlight.

Cualquier duda: el cÃ³digo Flutter estÃ¡ bien, solo es trabajo de configuraciÃ³n nativa.