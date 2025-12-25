import 'dart:convert';


import 'package:nexus_frontend/models/userModel.dart';
import 'package:http/http.dart' as http;

class AuthService{
  static const baseUrl = "http://10.161.162.75:3000/api/auth/";
  
   Future<UserModel?> registerUser(UserModel user) async
  {

    var url = Uri.parse("${baseUrl}register");

    try{
      final body = user.toJson();
      final res = await http.post(url, headers: {'Content-Type': 'application/json'}, body: json.encode(body));

      print(res.statusCode);

      if(res.statusCode == 201)
        {
          print("Success");
          final data = jsonDecode(res.body);

          UserModel myUser = UserModel.fromJson(data["user"]);
          return myUser;
        }

      else{
        print(res.body);
      }
      
    }
        catch(err)
    {
      print(err);
      Exception(err);
    }

    print("null");
    return null;
  }

   Future<UserModel?> loginUser(String email, String password) async
  {
    var url = Uri.parse("${baseUrl}login");



    try{
      final  body = {"email" : email, "password" : password};
      
      final res = await http.post(url, headers: {'Content-Type': 'application/json'}, body: json.encode(body));

      if(res.statusCode == 200)
        {
          final data = jsonDecode(res.body);
          UserModel currUser = UserModel.fromJson(jsonDecode(data["user"]));

          return currUser;
        }

      else{
        print(res.body);
      }


    }
        catch(err)
    {
      Exception(err);
    }

    return null;
  }

}