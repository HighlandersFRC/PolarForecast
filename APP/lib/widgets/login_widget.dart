import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scouting_app/api_service.dart';

class LoginWidget extends StatelessWidget {
  final String redirect_path;
  LoginWidget({Key? key, required this.redirect_path}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Text('You have to log in to view this content'),
          SizedBox(height: 10.0),
          ElevatedButton(
              onPressed: () {
                final apiService =
                    Provider.of<ApiService>(context, listen: false);
                apiService.login(redirect_path);
              },
              child: Text('Log in or Sign up'))
        ],
      ),
    );
  }
}
