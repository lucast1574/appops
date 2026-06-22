# Leasy Ops Mobile — Checklist iOS (para el equipo Mac)

> Este documento describe **lo que ya está hecho** en el proyecto Flutter y **lo que falta hacer obligatoriamente en una Mac** para tener el app en TestFlight / App Store.
>
> Mientras estés leyendo esto: el proyecto compila iOS a nivel de archivos (Podfile, Info.plist, AppDelegate.swift, project.pbxproj, Assets, GoogleService-Info.plist), pero **nunca se ha corrido `pod install` ni `flutter build ios` en una Mac real**. El primer build descubrirá si algún Pod tiene conflictos.

---

## 📦 Estado de configuración (ya hecho)

| Pieza | Estado | Notas |
|---|---|---|
| `ios/` directory tracked en git | ✅ Sí | Todo el contenido versionado |
| `Podfile` | ✅ | iOS 13.0 mínimo, `use_frameworks!`, `use_modular_headers!`, post_install fuerza 13.0 a todos los pods |
| `Info.plist` permission strings | ✅ | Camera, Location When/Always, Photo Library, Photo Add — todas en español |
| `Info.plist` UIBackgroundModes | ✅ | `fetch`, `remote-notification`, `location` declarados |
| `Info.plist` URL scheme Google Sign-In | ✅ | `com.googleusercontent.apps.863779943763-...` |
| `Info.plist` orientación | ✅ | Portrait-only |
| `Info.plist` Scene manifest | ✅ | iOS 13+ Scene/SceneDelegate registrados |
| `AppDelegate.swift` | ✅ | `FirebaseApp.configure()`, `UNUserNotificationCenter.delegate`, APNs → FCM token forwarding, MethodChannel `com.leasy.ops/settings` para abrir Settings de ubicación |
| `SceneDelegate.swift` | ✅ | Subclase de `FlutterSceneDelegate` |
| `Runner-Bridging-Header.h` | ✅ | Importa `GeneratedPluginRegistrant.h` |
| `GoogleService-Info.plist` | ✅ existe localmente, ❌ NO en git por seguridad | Compartir por canal seguro (vault/1Password/Notion). `BUNDLE_ID=com.leasy.ops.leasyOpsMobile`, `PROJECT_ID=opps-app-47b45` |
| `project.pbxproj` bundle id | ✅ | `com.leasy.ops.leasyOpsMobile` |
| `project.pbxproj` deployment target | ✅ | iOS 13.0 |
| `project.pbxproj` signing | ✅ Automatic + DEVELOPMENT_TEAM = `LA74BXZFC6` (Leasy) preconfigurado | No requiere acción en Xcode si el Apple ID del compañero pertenece a ese Team |
| `project.pbxproj` device family | `"1,2"` (iPhone + iPad) | Decidir si dejarlo universal o iPhone-only |
| `Assets.xcassets/AppIcon` | ✅ Generados desde `assets/icon.png`, sin alpha channel (flatten contra `#002B4A`) | Listos para App Store |
| Código Dart platform-aware | ✅ | `push_service.dart` bifurca iOS/Android. `location_permission_dialog.dart` tiene pasos específicos por plataforma |
| `flutter analyze` | ✅ Pasa sin warnings | Validado en Windows |

---

## ⚠️ Antes de empezar — NO copies la carpeta del PC

**Importante:** clona el repo desde GitHub, **NO copies la carpeta del proyecto de otra máquina** (USB, Dropbox, mail). Si lo haces, vas a traer archivos generados con paths Windows que rompen `pod install`:
- `ios/Flutter/Generated.xcconfig` (contiene `FLUTTER_ROOT=C:\Users\...`)
- `ios/Flutter/ephemeral/`
- `.dart_tool/`, `build/`

Si **ya copiaste** la carpeta (no clonaste), antes de hacer nada:

```bash
cd <ruta-del-proyecto>
rm -rf ios/Flutter/Generated.xcconfig ios/Flutter/ephemeral
rm -rf ios/Pods ios/Podfile.lock
rm -rf .dart_tool build
flutter pub get                                    # regenera Generated.xcconfig con paths Mac
cat ios/Flutter/Generated.xcconfig | head -3       # confirma: debe decir FLUTTER_ROOT=/Users/...
```

Recién después correr `pod install`.

---

## 🍎 Trabajo obligatorio en Mac

### 1. Setup de toolchain (una sola vez)
```bash
# Asumiendo macOS reciente
xcode-select --install                     # Command Line Tools
sudo gem install cocoapods                 # CocoaPods (o brew install cocoapods)
brew install --cask flutter                # o usar el mismo SDK que en Windows
flutter doctor                              # debe mostrar todo OK excepto Android si no lo usan
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

Ambos archivos están en `.gitignore`. Sin ellos Firebase no inicializa.

### 4. CocoaPods
```bash
cd ios
pod install --repo-update                   # baja pods (Firebase, google_sign_in, etc.)
# Si sale error de "deployment target": el Podfile ya fuerza 13.0, no debería pasar
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
En el target `Runner` → tab **Signing & Capabilities**:

1. **Team:** ya viene preconfigurado como `LA74BXZFC6` en el `project.pbxproj`. Solo verificar que aparezca seleccionado y sin warning rojo. Si el Apple ID del compañero del Mac NO pertenece a ese Team, hay que invitarlo desde App Store Connect → Users and Access antes.
2. **Bundle Identifier:** debe mostrar `com.leasy.ops.leasyOpsMobile`. Si Xcode lo cambia, restaurarlo.
3. Añadir capabilities (botón `+ Capability`):
   - **Push Notifications**
   - **Background Modes** → marcar:
     - Background fetch
     - Remote notifications
     - Location updates
   - **Sign in with Apple** (solo si en el futuro se requiere para review de Apple — opcional, hoy no se usa)

### 7. APNs Authentication Key en Firebase
**Crítico** — sin esto las push notifications iOS NUNCA llegan, aunque el código esté perfecto.

1. Apple Developer Portal → Keys → "+" → **APNs Authentication Key** (`.p8`).
2. Descargar el `.p8` (¡solo se puede descargar una vez!).
3. Anotar el `Key ID` y el `Team ID`.
4. Ir a Firebase Console → proyecto `opps-app-47b45` → Project Settings → Cloud Messaging → "Apple app configuration" → subir el `.p8` con su Key ID y Team ID.

Verificar: `FirebaseMessaging.instance.getAPNSToken()` debe devolver non-null en device físico.

### 8. App Icon
**Ya hecho.** Los íconos en `ios/Runner/Assets.xcassets/AppIcon.appiconset/` están generados desde `assets/icon.png` con `remove_alpha_ios: true` y `background_color_ios: "#002B4A"` (App Store rechaza íconos con alpha channel).

Si en el futuro cambias `assets/icon.png`, regenerar con:
```bash
dart run flutter_launcher_icons
```

### 9. Bundle Identifier en Firebase
Confirmar en Firebase Console que el iOS app del proyecto `opps-app-47b45` tiene:
- Bundle ID: `com.leasy.ops.leasyOpsMobile` (camelCase, no snake_case)
- App ID: `1:985287713026:ios:d6f754f3ebb038f3b0e21b`

Si no coincide, descargar un nuevo `GoogleService-Info.plist`.

### 10. Primer build de prueba (simulador)
```bash
flutter run -d "iPhone 15"   # o cualquier simulador disponible
```
- Verificar que arranca, muestra Splash, pide permiso de notificaciones, pide permiso de ubicación.
- Verificar que **NO crashea** al pedir permisos (en simulador la ubicación se simula desde Debug → Location).

### 11. Build en device físico
1. Conectar un iPhone con el mismo Apple ID o invitado al Team.
2. En Xcode confiar el certificado en el device (Settings → General → VPN & Device Management).
3. `flutter run --release -d <device>`.
4. Probar push notifications (mandar desde Firebase Console → Cloud Messaging → "Send your first message" usando el FCM token que imprime el log de la app).
5. Probar Google Sign-In real.
6. Probar el flujo de location "Siempre" (subir desde "When in use" en Settings).
7. Probar `image_picker` (cámara + galería) con foto real.

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

Luego en App Store Connect → Apps → Leasy Ops → TestFlight → asignar testers.

---

## ⚠️ Cosas que probablemente revienten en el primer build (y cómo arreglarlas)

### `pod install` falla con "CocoaPods could not find compatible versions"
→ Borrar `Podfile.lock`, `Pods/` y `~/Library/Caches/CocoaPods` → `pod repo update` → `pod install`.

### Error de Swift version
→ El `project.pbxproj` declara `SWIFT_VERSION = 5.0`. Si algún pod requiere Swift 5.5+, no debería ser problema en Xcode 14+.

### `Firebase.initializeApp()` falla en runtime
→ Probablemente falta `GoogleService-Info.plist` o no está agregado al target en Xcode (debe aparecer en el group `Runner` con check para target `Runner`).

### Push token no llega (`apnsToken` es nil)
→ Capability "Push Notifications" no activada en Xcode, o APNs Auth Key no subida a Firebase.

### Build falla con "Provisioning profile doesn't include the aps-environment entitlement"
→ Falta activar la capability "Push Notifications" — Xcode regenera el provisioning solo si la capability está marcada.

### `image_picker` crashea al tomar foto en iOS
→ Algún `NSPhotoLibraryUsageDescription` mal escrito. Ya están en el `Info.plist`, debería estar bien.

### Geolocator no pide "Always"
→ En iOS, "Always" solo se ofrece DESPUÉS de aceptar "When in use" y de que la app use ubicación en background. El flow del `permission_gate_page` ya maneja esto enviando al usuario a Settings.

---

## 📋 Resumen ultra-corto

**Para tu compañero Mac:**

1. Clonar repo, `flutter pub get`.
2. Pedir `GoogleService-Info.plist` y `google-services.json` por canal seguro y pegarlos.
3. `cd ios && pod install`.
4. Abrir `ios/Runner.xcworkspace` en Xcode.
5. Signing & Capabilities → Team ya viene como `LA74BXZFC6` (Leasy), solo activar Push Notifications + Background Modes (3 modos).
6. Subir APNs `.p8` a Firebase (proyecto `opps-app-47b45`).
7. ~~`dart run flutter_launcher_icons`~~ ya hecho desde el PC (Windows).
8. `flutter run` en simulador → device → `flutter build ipa --release` → TestFlight.

Cualquier duda: el código Flutter está bien, solo es trabajo de configuración nativa.
