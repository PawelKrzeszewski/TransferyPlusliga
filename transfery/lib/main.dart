import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:transfery/color_scheme.dart';
import 'main_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');
//  final IOSInitializationSettings initializationSettingsIOS =
//  IOSInitializationSettings();
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
//    iOS: initializationSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}


@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

}

void listenToTransfery() {
  FirebaseFirestore.instance
      .collection('transfery')
      .snapshots()
      .listen((QuerySnapshot snapshot) {
    // Dla każdej zmiany w kolekcji
    for (var change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.added) {
        // Nowy dokument został dodany
        _showNotification(
            "Nowy transfer", "Dodano nowy transfer do bazy danych.");
      } else if (change.type == DocumentChangeType.modified) {
        // Istniejący dokument został zmodyfikowany
        _showNotification("Transfer zaktualizowany",
            "Zaktualizowano dane w transferze.");
      }
    }
  });
}

Future<void> _showNotification(String title, String body) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
    'your_channel_id', // Define a channel id
    'your_channel_name', // Define a channel name
    channelDescription: 'your_channel_description',
    importance: Importance.max,
    priority: Priority.high,
  );
  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );
  await flutterLocalNotificationsPlugin.show(
    DateTime.now().millisecondsSinceEpoch, // Notification ID (unique for each notification)
    title,
    body,
    platformChannelSpecifics,
  );
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
  alert: true,
  announcement: false,
  badge: true,
  carPlay: false,
  criticalAlert: false,
  provisional: false,
  sound: true,
  );
  await Firebase.initializeApp(); // Inicjalizacja Firebase
  await initializeNotifications();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transfery Plusligi',
      theme: ThemeData(
        colorScheme: myColorScheme,
        appBarTheme: AppBarTheme(
          backgroundColor: myColorScheme.primary,
          foregroundColor: myColorScheme.onPrimary,
          elevation: 4
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.grey.shade800,
          backgroundColor: myColorScheme.primaryContainer,
        )
        ),

      ),
      home: MainPage(),
    );
  }
}
