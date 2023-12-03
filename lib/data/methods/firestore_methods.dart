import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreMethods {
  FirebaseFirestore db = FirebaseFirestore.instance;
  FirestoreMethods() {
    db = FirebaseFirestore.instance;
  }
  void addSignup(Map<String, dynamic> data) {
    db.collection("registrations").add({
      "name": data["name"],
      "username": data["username"],
      "password": data["password"],
      "purok": data["purok"],
      "status": data["status"],
      "barangay": data["barangay"],
      "email": data["email"],
      "date_applied": DateTime.now(),
      "profile_image": data["profile_picture_image"],
      "user_type": "passenger",
      "valid_id_image": data["valid_id_image"],
      "drivers_license_image": data["drivers_license_image"],
    });
  }

  Future<Map<String, dynamic>> login(
      {String? username, String? password}) async {
    Map<String, dynamic> result = {};
    await db
        .collection("users")
        .where(Filter.and(
            Filter("username", isEqualTo: username!),
            Filter("password", isEqualTo: password!),
            Filter("user_type", isEqualTo: "passenger")))
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        result = value.docs[0].data();
      }
    });
    return result;
  }
}
