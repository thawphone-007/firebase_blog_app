import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'profile_database.dart';
import 'profile_model.dart';

// ***** MAIN SIGN IN METHOD *****
Future<UserCredential?> signInWithGoogle() async {
  if (kIsWeb) {
    return await signInWithGoogleWeb();
  } else {
    return await signInWithGoogleMobile();
  }
}

// ***** GOOGLE SIGN IN WITH MOBILE *****
Future<UserCredential?> signInWithGoogleMobile() async {
  await GoogleSignIn.instance.initialize(
    clientId: "158882196078-aub31m9ajfp0iftj8gt54ao9q447ll8g.apps.googleusercontent.com",
  );
  final GoogleSignInAccount account = await GoogleSignIn.instance
      .authenticate();
  final GoogleSignInAuthentication authentication = account.authentication;
  final credential = GoogleAuthProvider.credential(
    idToken: authentication.idToken,
  );
  final userCredential = await FirebaseAuth.instance.signInWithCredential(
    credential,
  );
  // SAVE PROFILE TO FIRESTORE
  await _saveProfileToFirestore(userCredential);
  return userCredential;
}

// ***** GOOGLE SIGN IN WITH WEB *****
Future<UserCredential?> signInWithGoogleWeb() async {
  final GoogleAuthProvider provider = GoogleAuthProvider();
  final userCredential = await FirebaseAuth.instance.signInWithPopup(provider);
  // SAVE PROFILE TO FIRESTORE
  await _saveProfileToFirestore(userCredential);
  return userCredential;
}

// ***** SHARED USE: SAVE PROFILE TO FIRESTORE METHOD *****
Future<void> _saveProfileToFirestore(UserCredential userCredential) async {
  final ProfileDatabase profileDatabase = ProfileDatabase();
  await profileDatabase.createProfile(
    profileModel: ProfileModel(
      name: userCredential.user?.displayName ?? "",
      userId: userCredential.user?.uid ?? "",
      email: userCredential.user?.email ?? "",
      profilePicture: userCredential.user?.photoURL ?? "",
    ),
  );
}

// ***** AUTH STATE CHANGE *****
void listenAuthState(Function(User?) onChangeAuthState) {
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    onChangeAuthState(user);
  });
}
