import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:queueless/Customer/HomeScreen.dart';
import 'package:queueless/Customer/notification.dart';
// import 'package:queueless/Customer/LoginScreen.dart';
import 'package:queueless/SplashScreen.dart';
import 'package:queueless/admin/AdminHomePage.dart';
import 'package:queueless/constant/env.dart';
import 'package:queueless/firebase_options.dart';
import 'package:queueless/helper/Notification_Service.dart';
import 'package:queueless/helper/socketservice.dart';
import 'package:queueless/models/WorkerInformationModal.dart';
import 'package:queueless/models/businessInformationModal.dart';
import 'package:queueless/models/serviceInformationModal.dart';
import 'package:queueless/models/timeInformationModal.dart';
import 'package:queueless/worker/workerhomeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';


@pragma('vm:entry-point')
Future<void> _backgroundMessageHandler(RemoteMessage message)async{
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
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

class MyApp extends StatefulWidget {
  final String? token;
  const MyApp({super.key, required this.token});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
   final NotificationService notificationService = NotificationService();

  @override

  void initState() {

    super.initState();

    _initNotifications();

  }

  Future<void> _initNotifications() async {

    await notificationService.initLocalNotifications();

    notificationService.requestLNotificationPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {

      notificationService.showNotification(message);

    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationScreen(),));
    });

  }

  @override
  Widget build(BuildContext context) {
    bool isvalidtoken = widget.token != null && !JwtDecoder.isExpired(widget.token!);
    Widget screen;

    if (isvalidtoken) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.token!);
      String role = decodedToken["role"];
      if (role == "user") {
        screen = Homescreen();
      } else if(role == "worker") {
        screen = Workerhomescreen();
      } else{
        screen = Adminhomepage();
      }
    } else {
      screen = SplashScreen();
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
