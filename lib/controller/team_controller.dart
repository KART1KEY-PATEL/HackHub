import 'package:flutter/material.dart';
import 'package:hacknow/model/user_model.dart';

class TeamController with ChangeNotifier {
  String? _teamName;
  String? _teamLeaderId;
  List<String> _teamMembers = [];
  int _teamSize = 2;
  bool _registered = false;
  List<UserModel> _teamMemberDetails = [];

  // Getters
  String? get teamName => _teamName;
  String? get teamLeaderId => _teamLeaderId;
  List<String> get teamMembers => _teamMembers;
  int get teamSize => _teamSize;
  bool get registered => _registered;
  List<UserModel> get teamMemberDetails => _teamMemberDetails;

  // Setters
  void setTeamName(String name) {
    _teamName = name;
    notifyListeners();
  }

  void setTeamLeaderId(String id) {
    _teamLeaderId = id;
    notifyListeners();
  }

  void clearTeamMembers() {
    _teamMembers.clear();
    _teamMemberDetails.clear();
    notifyListeners();
  }

  void addTeamMember(String memberId) {
    _teamMembers.add(memberId);
    notifyListeners();
  }

  void setTeamSize(int size) {
    _teamSize = size;
    notifyListeners();
  }

  // Add this method to your TeamController class
  void addTeamMemberDetails(UserModel member) {
    // Check if member already exists in the list
    if (!_teamMemberDetails.any((existing) => existing.id == member.id)) {
      _teamMemberDetails.add(member);
      notifyListeners();
    }
  }

  void setRegistered(bool status) {
    _registered = status;
    notifyListeners();
  }

  void clear() {
    _teamName = null;
    _teamLeaderId = null;
    _teamMembers = [];
    _teamSize = 2;
    _registered = false;
    notifyListeners();
  }
}
