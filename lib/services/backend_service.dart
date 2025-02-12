import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gsheets/gsheets.dart';

import 'package:provider/provider.dart';

class Backendservice {
// Load JSON credentials
  Future<GSheets> loadGoogleSheets() async {
    String jsonCredentials =
        await rootBundle.loadString('assets/credentials.json');
    final credentials = jsonDecode(jsonCredentials);
    return GSheets(credentials);
  }

  Future<List<String>> fetchTeamMembers(String teamName) async {
    final gsheets = await loadGoogleSheets();
    final spreadsheetId =
        "12Sg_pWzVrDoz-icj9cMQrmLcj6rd-J8ALUQRSfx6rFg"; // Replace with actual ID
    final spreadsheet = await gsheets.spreadsheet(spreadsheetId);

    // Get the worksheet containing team data
    final worksheet =
        spreadsheet.worksheetByTitle('Teams'); // Change sheet name accordingly

    if (worksheet == null) {
      print("Worksheet not found");
      return [];
    }

    // Fetch all rows
    final rows = await worksheet.values.allRows();

    if (rows == null || rows.isEmpty) {
      print("No data found in the sheet");
      return [];
    }

    List<String> teamMembers = [];

    // Find the rows where Team Name matches and extract Participant Name
    for (var row in rows) {
      if (row.length > 3 && row[2] == teamName) {
        teamMembers.add(row[4]); // Column E (Participant Name)
      }
    }

    return teamMembers;
  }
}
