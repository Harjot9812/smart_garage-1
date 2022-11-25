import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:smart_garage/utils/preference_manager.dart';

class Config {
  static Uri urlLogin = Uri.parse("http://4.229.225.201:5000/login");
  Uri urlDoor = Uri.parse("http://4.229.225.201:5000/door?token=$token");
  Uri urlLight = Uri.parse("http://4.229.225.201:5000/light?token=$token");
  Uri urlCo = Uri.parse("http://4.229.225.201:5000/co?token=$token");
  Uri urlValid = Uri.parse("http://4.229.225.201:5000/?token=$token");
  Uri urlGuest = Uri.parse("http://4.229.225.201:5000/guest?token=$token");
  Uri urlAddGuest =
      Uri.parse("http://4.229.225.201:5000/add_guest?token=$token");
  Uri urlRevokeGuest =
      Uri.parse("http://4.229.225.201:5000/revoke_guest?token=$token");
  Uri urlSignUp = Uri.parse("http://4.229.225.201:5000/sign_up");

  static const String API_KEY = "b22e4e51-0fdf-4c75-9d95-f023e9c32c74";

  static String token = "";

  static String NONE = "_none";

  String getOccupancyValue(String value) {
    if (value == "0") {
      return "EMPTY";
    }
    return "FULL";
  }

  int getDoorValue(String v) {
    Map<String, dynamic> jsonObj = jsonDecode(v);
    return jsonObj["Door"];
  }

  int getDoorInt(String value) {
    switch (value) {
      case "OPEN":
        return 1;
      case "CLOSE":
        return -1;
      default:
        return 0;
    }
  }

  String getDoorString(int value) {
    switch (value) {
      case 1:
        return "OPEN";
      case -1:
        return "CLOSE";
      default:
        return "STOP";
    }
  }

  String getSwitchValue(String value) {
    if (value == "1") {
      return "ON";
    }
    return "OFF";
  }

  int getSwitchInt(String value) {
    if (value == "ON") {
      return 1;
    }
    return 0;
  }

  String getSwitchValueJson(String data, String light) {
    final body = json.decode(data);
    int value = body[light];
    if (value == 1) {
      return "ON";
    }
    return "OFF";
  }

  Color getCoColor(double level) {
    if (level > 0.50) {
      return Colors.red;
    } else if (level > 0.25) {
      return Colors.orange;
    } else if (level > 0.10) {
      return Colors.yellow;
    }
    return Colors.green;
  }

  String getSwitchValueInt(int value) {
    if (value == 1) {
      return "ON";
    }
    return "OFF";
  }

  List<int> getSwitchValueList(String data) {
    final body = json.decode(data);
    late List<int> list = [];
    list.add(body["Light_L"]);
    list.add(body["Light_M"]);
    list.add(body["Light_R"]);
    list.add(body["Light_Ext"]);
    return list;
  }

  String getSwitchValueIndoorJson(String data) {
    final body = json.decode(data);
    int valueL = body["Light_L"];
    int valueM = body["Light_M"];
    int valueR = body["Light_R"];
    int value = valueL + valueM + valueR;
    if (value > 0) {
      return "ON";
    }
    return "OFF";
  }

  double getCoLevelJson(String data) {
    final body = json.decode(data);
    return body["Co"] / 100;
  }

  List<dynamic> getGuests(String data) {
    final body = json.decode(data);
    List<dynamic> guestList = List.from(body);
    return guestList;
  }

  static String getConnectionStat(String resp) {
    final body = json.decode(resp);
    if (body["status"] == 1) {
      return "SUCCESS";
    } else {
      return "FAILURE";
    }
  }

  static String getToken(String resp) {
    final body = json.decode(resp);
    token = body["token"];
    return token;
  }

  static void saveToStorage(String key, String value) {
    Log.log(Log.TAG_STORAGE, "Saving to local", Log.I);
    PreferenceManager.setString(key, value);
  }

  static Future<dynamic> readFromStorage(String key, String def) {
    return PreferenceManager.getString(key, def);
  }

  static const String KEY_AUTH_ID = "auth_id";
  static const String KEY_USER = "user_name";
  static const String KEY_PASS = "user_pass";
  static const String KEY_DEVICE_ID = "user_id";

  static Future<bool> refreshToken() async {
    String email = "";
    String password = "";
    String device = "";
    final uri = urlLogin;
    final headers = {'Content-Type': 'application/json'};
    email = await readFromStorage(KEY_USER, "");
    password = await readFromStorage(KEY_PASS, "");
    device = await readFromStorage(KEY_DEVICE_ID, "");
    Map bData = {'email': email, 'password': password, 'Device': device};
    final body = json.encode(bData);

    http.Response response = await http.post(uri, headers: headers, body: body);

    int statusCode = response.statusCode;
    String responseBody = response.body;
    Log.log(Log.TAG_REQUEST, "$statusCode", Log.I);
    Log.log(Log.TAG_REQUEST, responseBody, Log.I);
    if (statusCode == 200) {
      saveToStorage(Config.KEY_AUTH_ID, Config.getToken(responseBody));
      return true;
    }
    return false;
  }
}

class Log {
  static const bool DEBUG = true;

  static const String E = "Error";
  static const String I = "Info ";

  static const String TAG_SPLASH = "Activity_Splash_Screen";
  static const String TAG_REQUEST = "Network_Requests      ";
  static const String TAG_STORAGE = "Storage_logs          ";
  static const String TAG_OPEN_SIGNAL = "One_Signal_logs       ";

  static void log(String tag, String message, String type) {
    if (DEBUG) {
      print("$tag : $type : $message");
    }
  }
}
