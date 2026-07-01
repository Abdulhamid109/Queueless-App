import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:queueless/Customer/HomeScreen.dart';
import 'package:queueless/Customer/LoginScreen.dart';
import 'package:queueless/admin/AdminHomePage.dart';
import 'package:queueless/constant/env.dart';
import 'package:queueless/helper/socketservice.dart';
import 'package:queueless/models/WorkerInformationModal.dart';
import 'package:queueless/models/businessInformationModal.dart';
import 'package:queueless/models/serviceInformationModal.dart';
import 'package:queueless/models/timeInformationModal.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(BusinessinformationmodalAdapter());
  Hive.registerAdapter(WorkerinformationmodalAdapter());
  Hive.registerAdapter(ServiceinformationmodalAdapter());
  Hive.registerAdapter(TimeinformationmodalAdapter());
  await Hive.openBox<Businessinformationmodal>("BusinessBox");
  await Hive.openBox<Workerinformationmodal>("WorkerBox");
  await Hive.openBox<Serviceinformationmodal>("ServiceBox");
  await Hive.openBox<Timeinformationmodal>("TimeBox");
  SharedPreferences pref = await SharedPreferences.getInstance();
  await dotenv.load(fileName: '.env');
  SocketService().init(serverUrl: BaseUrl);
  runApp(MyApp(token: pref.getString("token")));

}

class MyApp extends StatelessWidget {
  final String? token;
  const MyApp({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    bool isvalidtoken = token != null && !JwtDecoder.isExpired(token!);
    Widget screen;

    if (isvalidtoken) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token!);
      String role = decodedToken["role"];
      if (role == "user") {
        screen = Homescreen();
      } else {
        screen = Adminhomepage();
      }
    } else {
      screen = LoginScreen();
    }

    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Color.fromRGBO(249, 250, 251, 1),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
      ),
      home: screen,
      debugShowCheckedModeBanner: false,
    );
  }
}
