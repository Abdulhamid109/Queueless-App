import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:queueless/Widgets/CustomerAppbar.dart';
import 'package:queueless/Widgets/CustomerDrawer.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupport extends StatefulWidget {
  const HelpSupport({super.key});

  @override
  State<HelpSupport> createState() => _HelpSupportState();
}

class _HelpSupportState extends State<HelpSupport> {
Future<void> emailURLLauncher() async {
  final Uri gmailUri = Uri.parse(
    'googlegmail://co?to=queuelessindia@gmail.com',
  );

  if (await canLaunchUrl(gmailUri)) {
    await launchUrl(
      gmailUri,
      mode: LaunchMode.externalApplication,
    );
  } else {
    final Uri mailUri = Uri(
      scheme: 'mailto',
      path: 'queuelessindia@gmail.com',
    );

    await launchUrl(
      mailUri,
      mode: LaunchMode.externalApplication,
    );
  }
}

  Future<void> googleFormLauncher() async{
    final Uri googleformUri = Uri.parse(
      'https://forms.gle/bMqjmb4jtYZPpTpK6'
    );
    await launchUrl(
      googleformUri
    );
  }
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height*1;
    return Scaffold(
      appBar: Customerappbar(),
      drawer: Customerdrawer(),
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          children: [
            Center(child: Text("Help & Support",style: TextStyle(fontSize: 20),)),

            SizedBox(height: height*0.03,),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: Colors.blueGrey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ListTile(
                      title: Text("Reach out to us",style: TextStyle(color: Colors.white),),
                      subtitle: Text("queuelessindia@gmail.com",style: TextStyle(color: Colors.white)),
                      trailing:Card(
                        color: const Color(0xFFF9FAF9),
                        child: IconButton(onPressed: ()async=>emailURLLauncher(), icon: Icon(Icons.link)),),
                    ),
                  ),
                  Divider(thickness: 1,),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ListTile(
                      title: Text("Submit a Report/Bug",style: TextStyle(color: Colors.white)),
                      subtitle: Text("Help us understand the situation",style: TextStyle(color: Colors.white)),
                      trailing:Card(
                        color: const Color(0xFFF9FAF9),
                        child: IconButton(onPressed: ()async=>googleFormLauncher(), icon: Icon(Icons.bug_report)),),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}