# Leasy Ops — Mobile (Flutter)

App Android para **operarios** de Leasy: reciben tareas de campo asignadas
por el backoffice, las ejecutan con flujos guiados paso a paso, suben fotos
a S3, y reportan resultados.

- **Framework:** Flutter 3.9 (Dart SDK ^3.9)
- **Estado:** BLoC + GetIt (inyección)
- **HTTP:** Dio + interceptor JWT con auto-refresh
- **Auth:** google_sign_in + secure storage (Android KeyStore)
- **Modelos:** freezed + json_serializable
- **Prod API:** `https://api.opps-app.leasyauto.com/api/v1`

---

## 🧭 Estructura

```
lib/
  main.dart
  app.dart                          MaterialApp + theme (azul Leasy #002B4A)
  src/
    core/
      network/
        api_client.dart             Dio singleton + JWT refresh
        photo_upload_helper.dart    ImagePicker → presigned PUT S3 → confirm
      platform/
        native_settings.dart        MethodChannel para Android settings
    shared/
      widgets/                      Widgets genéricos (flow_*)
    features/
      auth/                         Splash, login, location gate
      home/                         Dashboard, listado de tareas
      history/                      Historial de tareas
      profile/                      Perfil del operario
      notifications/                Notificaciones
      verification/                 Flujo de verificación domiciliaria
      recovery/                     Flujo de recupero
      delivery/                     Flujo de entrega
      conversion/                   Flujo de conversión GNV/GLP
      transfer/                     Flujo de traslado
      vehicle_verification/         Flujo de verificar vehículo
      notary/                       Flujo de notaría
      management/                   Flujo de gestiones
      task_summary/                 Pantalla de resumen post-completado
```

Cada "feature" sigue el patrón:
```
presentation/
  pages/     Pantallas principales (ej. verification_page.dart)
  widgets/
    steps/   Un archivo por paso del flujo (paso 1, 2, 3...)
    shared/  Wrappers específicos de la feature (cuando hace falta)
```

---

## 🚀 Correr localmente

### 1. Prerrequisitos

- Flutter 3.9+ (`flutter --version`)
- Android Studio + emulador o device físico con USB debugging
- Llave SHA-1 del debug keystore registrada en Google Cloud (OAuth Client
  type Android). Pide al admin los JSON necesarios.

### 2. Instalar dependencias

```bash
flutter pub get
```

Si modificas modelos freezed / JSON serializable:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. Variables de entorno

Crea `.env` (ya está ignorado en git):

```env
# Apunta a backend local (usando adb reverse o ngrok) o prod
API_BASE_URL=https://api.opps-app.leasyauto.com/api/v1

# Google OAuth Android client id
GOOGLE_ANDROID_CLIENT_ID=...apps.googleusercontent.com
```

> **Nota:** actualmente `ApiClient._baseUrl` está hardcoded al prod en
> `lib/src/core/network/api_client.dart`. Para apuntar a local, edita
> temporalmente esa constante o parameteriza con `String.fromEnvironment`.

### 4. Correr

```bash
flutter run           # usa el device/emulador conectado
flutter run --release # para performance real
```

---

## 📦 Build de release

### APK
```bash
flutter build apk --release
# → build/app/outputs/flutter-apk/app-release.apk
```

### App Bundle (para Play Store)
```bash
flutter build appbundle --release
```

### Launcher icons (si cambias `assets/icon.png`)
```bash
dart run flutter_launcher_icons
```

---

## 🔐 Auth flow

1. `SplashPage` verifica si hay `access_token` en `flutter_secure_storage`.
2. Si no hay → `LoginPage` con botón Google.
3. `google_sign_in` devuelve `idToken` → `POST /users/auth/google/`.
4. Backend devuelve JWT (365 días) → se guarda en secure storage.
5. `ApiClient` adjunta `Authorization: Bearer ...` a cada request.
6. Si un request devuelve 401 → intenta refresh automático una vez.

> **Hardening:** `_readSafe` atrapa excepciones de KeychainAccess si el
> device resetea las llaves (ej. después de un wipe o factory reset).

---

## 📸 Subida de fotos (S3 presigned)

Flujo en `photo_upload_helper.dart`:

1. `ImagePicker` abre cámara o galería (max 1920×1920, quality 85).
2. `POST /tasks/<id>/photos/request-url/` → backend devuelve
   `{upload_url, s3_key}` (presigned PUT, 10 min validez).
3. `Dio.put(upload_url, bytes)` sube directo a S3 (no pasa por Django).
4. `POST /tasks/<id>/photos/confirm/` con `{s3_key, label, tag}` para
   registrar la foto en la DB.

---

## 📍 GPS + permisos

- `geolocator` para coordenadas.
- `permission_handler` para pedir permisos en runtime.
- `NativeSettings.openLocationPermission()` (MethodChannel) abre la
  pantalla exacta de permisos de ubicación en Android cuando el usuario
  niega `ALWAYS`.

El operario reporta su ubicación al backend en el heartbeat de tracking
(throttle de 30s).

---

## 🧪 Tests

Hoy en día `test/` solo tiene el default de Flutter. A medida que se
añadan, correr:

```bash
flutter test
```

---

## 🗂️ Apps hermanas

- **leasy_ops_backend** — la API Django que consume esta app
- **leasy_ops_backoffice** — el panel web Svelte para supervisores
