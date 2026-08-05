import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Changepasswordscreen extends StatefulWidget {
  final String email;
  const Changepasswordscreen({super.key,required this.email});

  @override
  State<Changepasswordscreen> createState() => _ChangepasswordscreenState();
}

class _ChangepasswordscreenState extends State<Changepasswordscreen> {
    TextEditingController newPassword = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  @override
  Widget build(BuildContext context) {
        double height = MediaQuery.of(context).size.height*1;

    return Scaffold(
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SizedBox(height: height*0.02,),
            Text("Change Your Password"),
            SizedBox(height: height*0.02,),
            TextFormField(
              controller: newPassword,
              decoration: InputDecoration(
                hintText: "New Password",
                focusedBorder: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder()
              ),
            ),
            SizedBox(height: height*0.01,),
            TextFormField(
              controller: newPassword,
              decoration: InputDecoration(
                hintText: "New Password",
                focusedBorder: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder()
              ),
            ),
            SizedBox(height: height*0.01,),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  backgroundColor: Colors.blue
                ),
                onPressed: (){}, child: Text("Change Password",style: TextStyle(color: Colors.white),)),
            )

          ],
        )
        ,
    );
  }
}