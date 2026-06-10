import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_kosmos/core_kosmos.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';

abstract class LocalAuthController {
  static Future<void> disbaleBiometrics() async {
    await LocalConfigController.setData("biometrics", boolValue: false);
    FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).collection("metadata").doc("security").update({
      "enableBiometricLogin": false,
    });
  }

  static Future<bool> enableBiometrics() async {
    final LocalAuthentication auth = LocalAuthentication();

    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();
    if (!canAuthenticate) return false;

    try {
      final bool didAuthenticate = await auth.authenticate(localizedReason: 'login');
      if (didAuthenticate) {
        await LocalConfigController.setData("biometrics", boolValue: true);
        FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).collection("metadata").doc("security").update({
          "enableBiometricLogin": true,
        });
        return true;
      }
    } catch (e) {
      printExcept(e);
    }
    return false;
  }

  static Future<void> registerPassword(String pass, [String? salt]) async {
    await LocalConfigController.setData("data", stringValue: KosmosHashController.encrypt(pass, salt));
  }

  static Future<bool> checkPassword(String pass, [String? salt]) async {
    final data = await LocalConfigController.getData<String?>("data");
    if (data == null) return false;
    return KosmosHashController.decrypt(data, salt) == pass;
  }

  static Future<void> saveEmail(String email) async {
    await LocalConfigController.setData("email", stringValue: email);
  }

  static Future<Tuple2<String, String>?> getLoginData([String? salt]) async {
    final email = await LocalConfigController.getData<String?>("email");
    final data = await LocalConfigController.getData<String?>("data");
    if (email == null || data == null) return null;
    return Tuple2(email, KosmosHashController.decrypt(data, salt));
  }
}
