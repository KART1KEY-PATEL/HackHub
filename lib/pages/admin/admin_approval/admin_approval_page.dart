import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hacknow/utils/custom_app_bar.dart';
import 'package:hacknow/utils/text_util.dart'; // Import txt() function

class AdminApprovalPage extends StatefulWidget {
  const AdminApprovalPage({super.key});

  @override
  State<AdminApprovalPage> createState() => _AdminApprovalPageState();
}

class _AdminApprovalPageState extends State<AdminApprovalPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to approve a user
  Future<void> approveUser(String userId) async {
    try {
      await _firestore
          .collection("users")
          .doc(userId)
          .update({"approved": true});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.greenAccent,
          content: txt("✅ User Approved Successfully!", isBold: true),
        ),
      );
    } catch (e) {
      print("🔥 Error approving user: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: txt("❌ Error approving user. Try again.", isBold: true),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(title: "Approval Page"),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A24), Color(0xFF252535)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection("users")
                .where("userType", isEqualTo: "volunteer")
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: CircularProgressIndicator(color: Colors.white));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                    child: txt("No Volunteers Found",
                        size: 16, isBold: true, color: Colors.white));
              }

              var allVolunteers = snapshot.data!.docs;
              var notApproved = allVolunteers
                  .where((doc) => doc["approved"] == false)
                  .toList();
              var approved = allVolunteers
                  .where((doc) => doc["approved"] == true)
                  .toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  txt("🚀 Volunteers Pending Approval",
                      size: 18, isBold: true, color: Colors.white),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: notApproved.length,
                      itemBuilder: (context, index) {
                        var user = notApproved[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          color: Color(0xFF2A2A3D),
                          elevation: 5,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            title: txt(
                                "${user["firstName"]} ${user["lastName"]}",
                                size: 16,
                                isBold: true,
                                color: Colors.white),
                            subtitle: txt("Phone: ${user["phoneNumber"]}",
                                size: 14, color: Colors.white70),
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => approveUser(user.id),
                              child: txt("Approve",
                                  size: 14, isBold: true, color: Colors.white),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  txt("✅ Approved Volunteers",
                      size: 18, isBold: true, color: Colors.white),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: approved.length,
                      itemBuilder: (context, index) {
                        var user = approved[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          color: Color(0xFF1D1D2D),
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            title: txt(
                                "${user["firstName"]} ${user["lastName"]}",
                                size: 16,
                                isBold: true,
                                color: Colors.white),
                            subtitle: txt("Phone: ${user["phoneNumber"]}",
                                size: 14, color: Colors.white70),
                            trailing: Icon(Icons.check_circle,
                                color: Colors.greenAccent),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
