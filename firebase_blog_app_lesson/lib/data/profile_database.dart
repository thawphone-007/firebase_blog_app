import 'package:cloud_firestore/cloud_firestore.dart';

import 'profile_model.dart';

class ProfileDatabase {
  final CollectionReference<ProfileModel> _profileCollection = FirebaseFirestore
      .instance
      .collection("profiles")
      .withConverter(
        fromFirestore: (snapshot, _) => ProfileModel.fromJson(snapshot),
        toFirestore: (profileModel, _) => profileModel.toJson(),
      );

  // Future<DocumentReference<ProfileModel>> createProfile({
  //   required ProfileModel profileModel,
  // }) async {
  //   return await _profileCollection.add(profileModel);
  // }

  // ✅ Document ID ကို userId နဲ့ သတ်မှတ်ပြီး set() သုံးတယ်
  Future<void> createProfile({required ProfileModel profileModel}) async {
    await _profileCollection.doc(profileModel.userId).set(
      profileModel,
      SetOptions(merge: true), // ရှိပြီးသားဆိုရင် ပေါင်းထည့်တယ်
    );
  }

  // Optional: Profile ကိုဖတ်တဲ့ Method
  Future<ProfileModel?> getProfile(String userId) async {
    final doc = await _profileCollection.doc(userId).get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }

}
