import 'package:flutter/foundation.dart';
import 'package:hacknow/model/user_model.dart';

class UserController with ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  void setUser(UserModel newUser) {
    _user = newUser;
    notifyListeners();
  }

  void updateUser({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? teamId,
    String? profilePhotoUrl,
    String? collegeName,
    bool? external,
    String? blockName,
    String? gender,
    String? collegeId,
    String? userType,
    String? userName,
    String? passWord,
    bool? approved,
    String? id,
  }) {
    if (_user != null) {
      _user = UserModel(
          userType: userType?.toString().split('.').last ?? _user!.userType,
          firstName: firstName ?? _user!.firstName,
          username: userName ?? _user!.username,
          password: passWord ?? _user!.password,
          lastName: lastName ?? _user!.lastName,
          phoneNumber: phoneNumber ?? _user!.phoneNumber,
          collegeName: collegeName ?? _user!.collegeName,
          external: external ?? _user!.external,
          gender: gender ?? _user!.gender,
          id: id?? _user!.id,
          approved: approved ?? _user!.approved);
      notifyListeners();
    }
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
