// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_just_for_fun/api/api_connections.dart';
import 'package:photo_just_for_fun/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:photo_just_for_fun/utils/permanent_functions.dart';

class RestApiLogAndRegistration {
  static Future<Map<String, dynamic>> login(
      Map<String, dynamic> data, BuildContext context) async {
    Map<String, dynamic> result = {};
    try {
      var response = await http.post(
          Uri.parse("${ApiConnections.BACKEND_URL}/login"),
          body: jsonEncode(data),
          headers: await ApiConnections.backend_headers());
      debugPrint("response: ${response.body}");
      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);
        if (json['success'] == true) {
          result['success'] = true;
          result['user'] = json['user'];
          result['token'] = json['token'];
        } else {
          result['success'] = false;
          PermanentFunctions.snack_bar("Error", "${json['message']}", true);
        }
      }
    } catch (e) {
      debugPrint("$e");
    }
    return result;
  }

  static Future<Map<String, dynamic>> check_token(String? token) async {
    Map<String, dynamic> results = {};
    try {
      var response = await http.get(
          Uri.parse("${ApiConnections.BACKEND_URL}/check/token"),
          headers: await ApiConnections.backend_headers());
      debugPrint("response check_token: ${response.body}");
      if (response.statusCode == 200) {
        results = jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint("$e");
    }
    return results;
  }

  static Future<UserModel?> update_user_model(Map<String, dynamic> data) async {
    UserModel? userModel;
    try {
      var req = http.MultipartRequest(
          'POST', Uri.parse('${ApiConnections.BACKEND_URL}/update/profile'))
        ..headers.addAll(await ApiConnections.backend_headers())
        ..fields.addAll({'user_fields': jsonEncode(data)});

      if (data['image_path'] != null) {
        print("image path:  ${data['image_path']}");
        req.files.add(await http.MultipartFile.fromPath(
            "${data['user_id']}", "${data['image_path']}"));
      }

      var res = await req.send();
      final respStr = await res.stream.bytesToString();
      debugPrint("change profile api ${respStr}");
      if (res.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(respStr);
        if (json['success'] == true) {
          userModel = UserModel.from_json(json['user']);
        }
      }
    } catch (e) {
      print(e);
    }
    return userModel;
  }
}
