import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:crypto/crypto.dart';

class CredentialsStore {
  final storage = new FlutterSecureStorage();

  Future<dynamic> getPass() async {
    final pass = await storage.read(key: 'OCS_PASS');
    return pass;
  }

  Future<void> setPass(pass) async {
    final bytes = utf8.encode(pass);
    final hash = md5.convert(bytes);
    await storage.write(key: 'OCS_PASS', value: hash.toString());
  }

  Future<dynamic> getUser() async {
    final user = await storage.read(key: "OCS_USER");
    return user;
  }

  Future<void> setUser(user) async {
    await storage.write(key: 'OCS_USER', value: user);
  }

  Future<dynamic> getJWT() async {
    final jwt = await storage.read(key: "OCS_JWT");
    return jwt;
  }

  Future<void> setJWT(jwt) async {
    await storage.write(key: "OCS_JWT", value: jwt);
  }

  Future<bool> checkLogged() async {
    final jwt = await getJWT() ?? "";
    if (jwt == "") return false;
    // This comes from using JS for too long
    print(jwt);

    final response = await http.get(
        Uri.https("ocs.iitd.ac.in", "/api/student/personal-info"),
        headers: {
          "Authorization": "Bearer $jwt",
          "User-Agent":
              "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36"
        });

    if (response.statusCode == 200) return true;
    return false;
  }

  Future<bool> login() async {
    final user = await getUser() ?? "";
    if (user == "") return false;
    final pass = await getPass() ?? "";
    if (pass == "") return false;

    final captcha =
        await http.get(Uri.https("ocs.iitd.ac.in", "/api/captcha"), headers: {
      "User-Agent":
          "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36"
    });
    if (captcha.statusCode != 200) {
      print("CAPTCHA Not loaded???");
      return false;
    }

    final challengeToken = jsonDecode(captcha.body)["token"] ?? "";
    if (challengeToken == "") {
      print("Invalid Token");
      return false;
    }

    final challenge = JwtDecoder.decode(challengeToken)["captcha"] ?? "";
    if (challenge == "") {
      print("Challenge Token not present");
      return false;
    }

    final obj = {
      "username": user,
      "password": pass,
      "captcha": challenge,
      "captchaToken": challengeToken
    };

    print(obj);

    final response = await http.post(
        Uri.https("ocs.iitd.ac.in", "/api/student/login"),
        body: jsonEncode(obj),
        headers: {
          "Content-Type": "application/json",
          "User-Agent":
              "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36"
        });

    if (response.statusCode != 200) {
      print(response.body);
      return false;
    }

    final jwt = response.body.toString();
    print({jwt});
    await setJWT(jwt.substring(1, jwt.length - 1));

    return true;
  }

  Future<void> logout() async {
    await storage.deleteAll();
  }
}
