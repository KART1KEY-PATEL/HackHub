import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hacknow/model/user_model.dart';
import 'package:hive/hive.dart';

class FoodService {
  // This function works perfectly as long as the diet times on the settings document are correct. The role of this function is to set the meal to true and assign the volunteer's QR code to the meal.
  Future<Map<String, String>> giveFoodToUser(String participantUserId) async {
    print("Message from food data: request sending");
    FirebaseFirestore db = FirebaseFirestore.instance;
    Box userBox = await Hive.openBox<UserModel>('userBox');
    String volunteerUserId = userBox.get("currentUser")!.id;
    Map<String, dynamic> previousFoodData =
        await __getPreviousFoodData(participantUserId);
    List<DateTime> mealtimes = await __getMealTimes();
    if (mealtimes.isEmpty) {
      return {
        "message": "Error fetching meal times. Check your connection.",
        "status": "error"
      };
    }
    DateTime meal1StartTime = mealtimes[0], meal1EndTime = mealtimes[1];
    DateTime meal2StartTime = mealtimes[2], meal2EndTime = mealtimes[3];
    DateTime meal3StartTime = mealtimes[4], meal3EndTime = mealtimes[5];

    String volunteerForMeal1 = previousFoodData["volunteerForMeal1"] as String;
    String volunteerForMeal2 = previousFoodData["volunteerForMeal2"] as String;
    String volunteerForMeal3 = previousFoodData["volunteerForMeal3"] as String;

    bool meal1 = previousFoodData["meal1"] as bool;
    bool meal2 = previousFoodData["meal2"] as bool;
    bool meal3 = previousFoodData["meal3"] as bool;

    DateTime currentTime = DateTime.now();

    if (currentTime.isBefore(meal1EndTime) &&
        currentTime.isAfter(meal1StartTime)) {
      if (previousFoodData["meal1"] == true) {
        // Send error message to the user that the meal has already been taken.
        return {"message": "Participant already had food.", "status": "error"};
      }
      meal1 = true;
      volunteerForMeal1 = volunteerUserId;
    } else if (currentTime.isBefore(meal2EndTime) &&
        currentTime.isAfter(meal2StartTime)) {
      if (previousFoodData["meal2"] == true) {
        // Send error message to the user that the meal has already been taken.
        return {"message": "Participant already had food.", "status": "error"};
      }
      meal2 = true;
      volunteerForMeal2 = volunteerUserId;
    } else if (currentTime.isBefore(meal3EndTime) &&
        currentTime.isAfter(meal3StartTime)) {
      if (previousFoodData["meal3"] == true) {
        // Send error message to the user that the meal has already been taken.
        return {"message": "Participant already had food.", "status": "error"};
      }
      meal3 = true;
      volunteerForMeal3 = volunteerUserId;
    } else {
      // This should never be called if the time in the settings document is correct, but I wrote it because I am paranoid.
      debugPrint("Error, possibly on the meal start and endtimings.");
      return {"message": "Error: Wrong times set for food.", "status": "error"};
    }
    final Map<String, dynamic> dataToBeUpdated = {
      "meal1": meal1,
      "volunteerForMeal1": volunteerForMeal1,
      "meal2": meal2,
      "volunteerForMeal2": volunteerForMeal2,
      "meal3": meal3,
      "volunteerForMeal3": volunteerForMeal3,
    };
    try {
      await db
          .collection("food")
          .doc(participantUserId)
          .update(dataToBeUpdated);
      return {
        "message": "Person can have the food",
        "status": "done",
      };
    } catch (error) {
      debugPrint("Error updating data");
      return {"message": "Error updating the database", "status": "error"};
    }
    return {"message": "Error updating the database", "status": "error"};
  }

  Future<List<DateTime>> __getMealTimes() async {
    List<DateTime> mealTimes = [];
    FirebaseFirestore db = FirebaseFirestore.instance;
    try {
      DocumentSnapshot snapshot =
          await db.collection('settings').doc('settings').get();
      if (snapshot.exists) {
        mealTimes.add(snapshot["diet1StartTime"].toDate());
        mealTimes.add(snapshot["diet1EndTime"].toDate());
        mealTimes.add(snapshot["diet2StartTime"].toDate());
        mealTimes.add(snapshot["diet2EndTime"].toDate());
        mealTimes.add(snapshot["diet3StartTime"].toDate());
        mealTimes.add(snapshot["diet3EndTime"].toDate());
      } else {
        debugPrint("No data found");
      }
    } catch (e) {
      debugPrint("Error fetching meal times: $e");
    }
    return mealTimes;
  }

  Future<Map<String, dynamic>> __getPreviousFoodData(String uuid) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    Map<String, dynamic> previousFoodData = {};
    try {
      previousFoodData = await db
          .collection("food")
          .doc(uuid)
          .get()
          .then((value) => value.data() as Map<String, dynamic>)
          .onError((error, stackTrace) {
        return {};
      });
    } catch (e) {
      if (e == "storage/object-not-found") {
        debugPrint("Not a user");
      }
    }

    return previousFoodData;
  }

  Future<UserModel?> getUserByUuid(String uuid) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    try {
      final DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uuid).get();
      print("User Data; fukc ");
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        print("User Data; ${userData['firstName']}");
        return UserModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }
}
