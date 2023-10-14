import 'package:e_voting_app/bidings/auth_binding.dart';
import 'package:e_voting_app/controllers/add_vote_option.dart';
import 'package:e_voting_app/controllers/auth_controller.dart';
import 'package:e_voting_app/controllers/election_controller.dart';
import 'package:e_voting_app/controllers/user_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/screens.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => ElectionController()),
      ],
      child: GetMaterialApp(
        onInit: () {
          Get.put<ElectionController>(ElectionController());
          Get.put<AuthController>(AuthController());
          Get.put<UserController>(UserController());
          Get.put<CandidateController>(CandidateController());
        },
        initialBinding: AuthBinding(),
        debugShowCheckedModeBanner: false,
        defaultTransition: Transition.noTransition,
        title: 'Election',
        home: FirebaseAuth.instance.currentUser == null
            ? const Login()
            : const ElectChain(),
        theme: ThemeData(
          textTheme: GoogleFonts.latoTextTheme(Theme.of(context).textTheme),
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        darkTheme: ThemeData(
          textTheme: GoogleFonts.latoTextTheme(Theme.of(context).textTheme),
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/',
        routes: {
          'auth': (context) => const AuthScreen(),
          'settings': (context) => const ElectChain(),
          'profile': (context) => const ElectChain(),
          'create_vote': (context) => const NewVote(),
        },
      ),
    );
  }
}

// class ElectChain extends StatefulWidget {
//   @override
//   _ElectChainState createState() => _ElectChainState();
// }

// class _ElectChainState extends State<ElectChain> {
//   final GlobalKey _scafflofKey = GlobalKey();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.green[100],
//       key: _scafflofKey,
//       appBar: AppBar(
//         //  leading: IconButton(
//         //   icon: Icon(Icons.dashboard),
//         //  onPressed: () {
//         //     Scaffold.of(context).openDrawer();
//         // }),
//         flexibleSpace: Container(
//           decoration: BoxDecoration(
//               gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: <Color>[Colors.green, Colors.blue])),
//         ),
//         elevation: 0.0,
//         title: Shimmer.fromColors(
//           baseColor: Colors.white,
//           highlightColor: Colors.blue,
//           child: Text('ElectChain',
//               style: GoogleFonts.loversQuarrel(
//                   fontSize: 48.0, fontWeight: FontWeight.bold)),
//         ),
//         actions: [
//           // ignore: missing_required_param

//           IconButton(
//               color: Colors.white,
//               icon: Icon(Icons.how_to_vote_rounded),
//               onPressed: () {}),
//           Container(
//             decoration: BoxDecoration(shape: BoxShape.circle),
//             child: IconButton(
//                 color: Colors.white,
//                 icon: Icon(Icons.info_outline_rounded),
//                 onPressed: () {
//                   showAboutDialog(
//                       context: context,
//                       applicationVersion: '^1.0.0',
//                       applicationIcon: CircleAvatar(
//                         radius: 30.0,
//                         backgroundColor: Colors.transparent,
//                         backgroundImage: AssetImage('assets/icons/icon.png'),
//                       ),
//                       applicationName: 'ElectChain',
//                       applicationLegalese: 'Brave Tech Solutions');
//                 }),
//           ),
//         ],
//       ),
//       body: HomeScreen(),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => print('Floating Action button pressed'),
//         child: Container(
//           decoration: BoxStyles.gradientBox,
//           child: IconButton(
//               icon: Icon(Icons.how_to_vote_rounded),
//               onPressed: () => print('How to vote')),
//         ),
//       ),
//       drawer: CustomDrawer(),
//     );
//   }
// }
