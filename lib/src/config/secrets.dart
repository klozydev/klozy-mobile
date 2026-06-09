// This file is encrypted at rest with git-crypt.
// On a fresh clone you must run `git-crypt unlock` (or `git-crypt unlock <key>`)
// before the project will build. Plaintext credentials must NEVER be committed
// without git-crypt being initialised on this repo.

class Secrets {
  Secrets._();

  // Populate with real values when integrations are wired up.
  static const String firebaseAndroidApiKey = '';
  static const String firebaseAndroidAppId = '';
  static const String firebaseMessagingSenderId = '';
  static const String firebaseProjectId = '';
  static const String firebaseStorageBucket = '';
}
