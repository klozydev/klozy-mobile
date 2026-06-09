# Klozy project

In this page you will find a general info related on how to run the project, the architecture used, and other things worth knowing.

## Project Architecture

In this project we use [clean architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html) by Robert C. Martin, in each feature directory you will find 3 main folders

- Data
- Domain
- Presentation

Each feature can depends on other features domain only, features can't depends on other features presentation or data, the following diagram will explain the relation between app and features.

![](images/app_arch.jpg)

## Base URL

To change the base url for the API you can change these two files 

- lib/src/core/network/dev_base_url.dart
- lib/src/core/network/prod_base_url.dart

The first one is for development build and the second one for production build.

## Navigation

For navigation we use [auto_route](https://pub.dev/packages/auto_route) package which depends on code generation to generate the routes between screens, using this package allow us to have a build time validation over paths.

## Run

To be able to run the project you to follow the following steps:

- Clone the repo
- Download & Install [Android Studio](https://developer.android.com/studio)
- Download & Install [Flutter](https://docs.flutter.dev/get-started/install/macos) version `3.32.0` is required
- Download & Install [Xcode](https://developer.apple.com/xcode/)

After doing all the above steps you should be able to run the following command

```bash
$ flutter doctor
```

If the result is look like the following image then you are good to go to the next step

![](images/flutter_doctor.png)

Because the project is depend on code generation so we need to trigger the code generation to generate the needed code for us before we can run the project, to do so you need to run the following command.

```bash
dart run build_runner build --delete-conflicting-outputs
```

Once you done with the above steps then you are good to go and run the project, now you need to connect your Android phone through USB with USB Debugging enabled, you should see your device appears on Android Studio toolbar, after that click on run button.

![](images/android_studio_run.png)

If the run button is disabled you need to go to `lib/main.dart` and scroll down to the main function and click on the left run button.

![](images/android_studio_main_function_run.png)


# Setup
You need some dart global packages to be able to run the project, you can install them by running the following command

```bash
dart pub global activate mason_cli
dart pub global activate flutter_gen
```

# Generate files
To generate the needed files for the project you need to run the following command

```bash
dart run build_runner build --delete-conflicting-outputs
```
The above command needed to be run every time you add a new file or change a file that is needed to be generated.

# Generate assets
To generate the needed assets for the project you need to run the following command

```bash
fluttergen
```
The above command needed to be run every time you add a new asset or change an asset that is needed to be generated.

# Generate a new feature
To generate a new feature you need to run the following command

```bash
cd mason
mason get # You need to run this only first time
mason make feature -o ../lib/src/feature
```
The above command will ask you for the feature name, after that it will generate the needed files for the feature.

# Datadog observability

The app reports RUM sessions, logs, network requests, and crashes to Datadog (EU site, `datadoghq.eu`). Wiring lives in `lib/src/core/observability/` and is initialised from `lib/main.dart` via `DatadogSdk.runApp`. The Datadog credentials live in `lib/src/config/secrets.dart`, which is **encrypted at rest with `git-crypt` using per-user GPG keys**. The `.gitattributes` file tells git-crypt which paths to encrypt — do not move `secrets.dart` without updating it.

If `secrets.dart` has empty credential strings, the app skips Datadog initialisation and runs normally — this lets new contributors clone, run, and develop locally before being granted decryption access.

## Onboarding a new developer

When someone joins the team, they need a personal GPG key that an existing maintainer adds to the repo. After that one-time bootstrap they can decrypt the secrets on every clone with no further coordination.

### A. The new developer (one-time setup on their machine)

1. Install the tools:
   ```bash
   brew install git-crypt gnupg
   ```
2. Generate a personal GPG key (skip if they already have one for this email):
   ```bash
   gpg --full-generate-key
   # Choose: (1) RSA and RSA, 4096 bits, never expires, real name + work email, set a passphrase.
   ```
3. Find the key id:
   ```bash
   gpg --list-secret-keys --keyid-format=long
   # sec   rsa4096/ABCD1234EF567890 2026-04-29 [SC]
   #       (this long hex after rsa4096/ is the key id)
   ```
4. Export the **public** key and send it to a maintainer through any channel (Slack, email — public keys are not secret):
   ```bash
   gpg --armor --export ABCD1234EF567890 > my-pubkey.asc
   ```

### B. The maintainer (grants the new developer access)

1. Import their public key:
   ```bash
   gpg --import my-pubkey.asc
   ```
2. Add them to the repo. `--trusted` skips the interactive trust prompt — only use it if you have verified the key fingerprint with the dev out-of-band:
   ```bash
   git-crypt add-gpg-user --trusted ABCD1234EF567890
   ```
   This creates a small file under `.git-crypt/keys/default/0/<fingerprint>.gpg` containing the repo symmetric key encrypted to the developer's public GPG key.
3. Commit and push:
   ```bash
   git push
   ```

### C. The new developer (after access is granted)

```bash
git pull
git-crypt unlock
# secrets.dart is now plaintext on their disk
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

`git-crypt unlock` finds the entry encrypted to their GPG key, decrypts the symmetric key with their private GPG, then transparently decrypts any encrypted files in the working tree. They will be prompted for their GPG passphrase the first time.

### Removing access

`git-crypt rm-gpg-user` exists but **revoking access requires rotating the symmetric key**, otherwise the removed user can still decrypt with the copy they already have. To rotate:

```bash
# Re-init with a new key. Old encrypted blobs in history remain readable to anyone
# with the old key, so for a real revocation, also rewrite history or rotate the
# tokens themselves in Datadog.
git-crypt init
# Then re-add the remaining team members:
git-crypt add-gpg-user --trusted <key-id-1>
git-crypt add-gpg-user --trusted <key-id-2>
git push
```

For Datadog credentials the practical answer when someone leaves is **rotate the client token in Datadog** rather than fight git history.

## Generating Datadog credentials

Required GitHub secrets and Datadog values:

1. Sign in to https://app.datadoghq.eu (the EU site).
2. **Real User Monitoring → New Application → Flutter.** Name it `Klozy`, generate, copy:
   - `applicationId` (UUID)
   - `clientToken` (starts with `pub`)
3. Paste both into `lib/src/config/secrets.dart` (this file must be unlocked via git-crypt first).
4. **Organization Settings → API Keys → New Key.** Copy the key — it's used by CI to upload symbol files. Add it as the `DATADOG_API_KEY` GitHub Actions secret.

## CI: Datadog symbol upload (`.github/workflows/datadog_symbols.yml`)

Runs on every `v*` tag push and on manual dispatch. Builds release artifacts with `--obfuscate --split-debug-info=build/symbols`, then uploads Dart symbols + Android R8 mapping (Linux job) and Dart symbols + iOS dSYMs (macOS job) via `npx @datadog/datadog-ci flutter-symbols upload`. Without this step, RUM stack traces from obfuscated release builds are unreadable.

The workflow needs three GitHub Actions secrets:

| Secret | What it is | How to generate |
|---|---|---|
| `DATADOG_API_KEY` | Datadog API key with intake permissions on EU1 | Datadog UI → Organization Settings → API Keys |
| `GIT_CRYPT_GPG_PRIVATE_KEY` | Base64-encoded armored private GPG key for the CI bot identity | See "Setting up the CI GPG identity" below |
| (none for `GIT_CRYPT_GPG_PUBLIC_KEY`) | Not needed; the public key gets committed to the repo via `git-crypt add-gpg-user` | — |

### Setting up the CI GPG identity

CI uses a dedicated GPG identity (not your personal key) so its access can be revoked independently. Generate a passphrase-less key — workflows can't type a passphrase. Run this **on your machine, once**:

```bash
gpg --batch --gen-key <<'EOF'
%no-protection
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: Klozy CI
Name-Email: ci@klozy.local
Expire-Date: 0
%commit
EOF
```

Find its id, then export the **private** key as base64 for the GitHub secret:

```bash
gpg --list-secret-keys --keyid-format=long ci@klozy.local
# Copy the long key id, e.g. CAFE1234CAFE5678
gpg --export-secret-keys --armor ci@klozy.local | base64 | pbcopy
```

Paste into GitHub → Settings → Secrets and variables → Actions → **New repository secret** → name `GIT_CRYPT_GPG_PRIVATE_KEY`.

Then add the CI identity to the repo (this commits a small encrypted-to-CI key file under `.git-crypt/`):

```bash
git-crypt add-gpg-user --trusted ci@klozy.local
git push
```

The workflow's `Import CI GPG key` step does `base64 -d | gpg --batch --import`, then `git-crypt unlock` finds the entry encrypted to the CI key and decrypts the repo. After that it can read `secrets.dart` and run the Datadog upload script normally.

## Manual symbol upload from a workstation

If you ever need to run the upload locally (for example, debugging a bad mapping), run from the repo root with the symmetric Datadog API key in your environment:

```bash
export DATADOG_API_KEY=...     # from Datadog → Organization Settings → API Keys
export DATADOG_SITE=datadoghq.eu
./scripts/datadog_upload_symbols.sh android
./scripts/datadog_upload_symbols.sh ios   # macOS only
```

The script reads the version from `pubspec.yaml`, builds with obfuscation + split debug info, and invokes `npx --yes @datadog/datadog-ci flutter-symbols upload`. The version it reports to Datadog must match the version your installed app reports (the SDK reads it from `pubspec.yaml` automatically).

# Firebase + App Distribution

Builds are distributed to internal testers via Firebase App Distribution. Configuration lives in the **Klozy-App** Firebase project (project ID `thawbwateeb-app`, project number `549258853621`). The Android app id registered in that project is `1:549258853621:android:a793856993008b54edd9bc` for package `com.klozy.app`.

`firebase_core` is initialised in `lib/main.dart` from `lib/firebase_options.dart`. The Firebase Dart-side values (api key, app id, project id, sender id, storage bucket) live as constants on `Secrets` in `lib/src/config/secrets.dart` — the same encrypted file that holds the Datadog credentials — and `firebase_options.dart` simply references those constants. So `firebase_options.dart` itself stays plaintext; the only encrypted Firebase artefact in the Dart tree is `secrets.dart`.

`android/app/google-services.json` is required by the `com.google.gms.google-services` Gradle plugin at build time and contains the same values as raw JSON. Gradle can't read Dart constants, so this file is encrypted via git-crypt directly. `android/key.properties` and `android/upload-keystore.jks` are likewise encrypted via git-crypt.

Firebase config values (API key, app id) are not technically secrets — Firebase ships them inside the published app — but they're encrypted here for symmetry with the rest of the project's credential storage.

Note: re-running `flutterfire configure` regenerates `firebase_options.dart` with hardcoded values, overwriting the references to `Secrets`. After every `flutterfire configure` run, re-apply the rewrite (or copy the new values into `Secrets` and restore the references).

## Android signing

The release keystore is at `android/upload-keystore.jks` (encrypted at rest). Its password and alias are in `android/key.properties` (also encrypted). Every release-mode and debug-mode Android build uses this keystore — see `android/app/build.gradle`.

**Do not lose the keystore password.** A lost keystore means you can never push another update under the same signing identity. The password is committed (encrypted) to the repo, so as long as the git-crypt unlock key is available the keystore is recoverable.

To rotate the keystore later:

```bash
keytool -genkeypair \
  -alias upload \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -storetype JKS \
  -keystore android/upload-keystore.jks \
  -storepass <new-password> \
  -keypass <new-password> \
  -dname "CN=Klozy, OU=Mobile, O=Klozy, L=Unknown, S=Unknown, C=US"
# Then update android/key.properties with the new password and commit.
```

Rotating the keystore breaks installs over previous releases — testers will have to uninstall and reinstall.
