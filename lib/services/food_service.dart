import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hacknow/model/user_model.dart';
import 'package:hive/hive.dart';

class FoodService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final int _totalMeals = 8;

  Future<Map<String, String>> giveFoodToUser(String participantUserId) async {
    debugPrint("FoodService: Processing food request");
    try {
      final userBox = await Hive.openBox<UserModel>('userBox');
      final volunteerUserId = userBox.get("currentUser")!.id;
      final previousFoodData = await _getPreviousFoodData(participantUserId);
      final mealtimes = await _getMealTimes();

      if (mealtimes.isEmpty) {
        return _errorResponse(
            "Error fetching meal times. Check your connection.");
      }

      final currentTime = DateTime.now();
      int? currentMealIndex;

      // Find which meal period we're in
      for (int i = 0; i < _totalMeals; i++) {
        final startIndex = i * 2;
        final endIndex = startIndex + 1;

        if (startIndex >= mealtimes.length || endIndex >= mealtimes.length) {
          return _errorResponse("Meal times data is incomplete");
        }

        if (currentTime.isAfter(mealtimes[startIndex]) &&
            currentTime.isBefore(mealtimes[endIndex])) {
          currentMealIndex = i;
          break;
        }
      }

      if (currentMealIndex == null) {
        return _errorResponse("No active meal period at this time");
      }

      final mealKey = 'meal${currentMealIndex + 1}';
      final volunteerKey = 'volunteerForMeal${currentMealIndex + 1}';

      if (previousFoodData[mealKey] == true) {
        return _errorResponse("Participant already had this meal");
      }

      final dataToUpdate = {
        mealKey: true,
        volunteerKey: volunteerUserId,
      };

      await _db.collection("food").doc(participantUserId).update(dataToUpdate);
      return _successResponse("Meal successfully recorded");
    } catch (e) {
      debugPrint("FoodService Error: $e");
      return _errorResponse("An error occurred while processing the request");
    }
  }

  Future<List<DateTime>> _getMealTimes() async {
    try {
      final snapshot = await _db.collection('settings').doc('settings').get();
      if (!snapshot.exists) {
        debugPrint("Settings document not found");
        return [];
      }

      final data = snapshot.data()!;
      final mealTimes = <DateTime>[];

      for (int i = 1; i <= _totalMeals; i++) {
        final startTime = data["diet${i}StartTime"]?.toDate();
        final endTime = data["diet${i}EndTime"]?.toDate();

        if (startTime == null || endTime == null) {
          debugPrint("Missing time for meal $i");
          return [];
        }

        mealTimes.addAll([startTime, endTime]);
      }

      return mealTimes;
    } catch (e) {
      debugPrint("Error fetching meal times: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>> _getPreviousFoodData(String uuid) async {
    try {
      final doc = await _db.collection("food").doc(uuid).get();
      return doc.data() ?? {};
    } catch (e) {
      debugPrint("Error fetching food data: $e");
      return {};
    }
  }

  Future<UserModel?> getUserByUuid(String uuid) async {
    try {
      final userDoc = await _db.collection('users').doc(uuid).get();
      if (userDoc.exists) {
        return UserModel.fromJson(userDoc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching user: $e');
      return null;
    }
  }

  Map<String, String> _successResponse(String message) {
    return {"message": message, "status": "done"};
  }

  Map<String, String> _errorResponse(String message) {
    return {"message": message, "status": "error"};
  }
}
