import 'package:e_voting_app/config/styles.dart';
import 'package:e_voting_app/controllers/auth_controller.dart';
import 'package:e_voting_app/controllers/election_controller.dart';
import 'package:e_voting_app/controllers/user_controller.dart';
import 'package:e_voting_app/models/election_model.dart';
import 'package:e_voting_app/models/user.dart';
import 'package:e_voting_app/screens/cast_vote.dart';
import 'package:e_voting_app/screens/create_vote.dart';
import 'package:e_voting_app/screens/user_elections.dart';
import 'package:e_voting_app/widgets/action_box.dart';
import 'package:e_voting_app/widgets/drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class ElectChain extends StatefulWidget {
  const ElectChain({super.key});

  @override
  _ElectChainState createState() => _ElectChainState();
}

class _ElectChainState extends State<ElectChain> {
  final GlobalKey _scafflofKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    context.read<AuthController>().readUser();

    return Scaffold(
      backgroundColor: Colors.green[100],
      key: _scafflofKey,
      appBar: AppBar(
          //  leading: IconButton(
          //   icon: Icon(Icons.dashboard),
          //  onPressed: () {
          //     Scaffold.of(context).openDrawer();
          // }),
          flexibleSpace: Container(),
          elevation: 0.0,
          title: Title(color: Colors.green, child: const Text("E-Voting"))),
      body: const HomeScreen(),
      drawer: const CustomDrawer(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _electionAccessCodeController =
      TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // SizedBox(height: 30.0),
            Text(
              "ENTER A VOTE CODE",
              style: GoogleFonts.roboto(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    width: MediaQuery.of(context).size.width * 0.60,
                    height: 50.0,
                    margin: const EdgeInsets.only(top: 20.0),
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(18.0)),
                    child: Form(
                      key: GlobalKey<FormState>(),
                      child: TextFormField(
                        controller: _electionAccessCodeController,
                        keyboardType: TextInputType.text,
                        style: TextStyle(
                          fontSize: 22.0,
                          color: Colors.green[400],
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18.0)),
                          hintText: "Enter the election code",
                          hintStyle: const TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.normal),
                          prefixIcon: const Icon(
                            Icons.lock,
                          ),
                        ),
                      ),
                    )),
                Container(
                  margin: const EdgeInsets.only(top: 20.0, left: 5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  child: ElevatedButton.icon(
                      onPressed: () async {
                        FirebaseFirestore firestore =
                            FirebaseFirestore.instance;
                        List<UserModel> allUsers = [];
                        List<ElectionModel> allElections = [];
                        var usersQuerySnap =
                            firestore.collection("users").get();
                        usersQuerySnap.then((usersQuery) {
                          var allUsers0 = usersQuery.docs
                              .map((user) => Get.find<UserController>()
                                  .fromDocumentSnapshot(user))
                              .toList();

                          for (var user in allUsers0) {
                            print(user.email);
                            firestore
                                .collection("users")
                                .doc(user.id)
                                .collection("elections")
                                .get()
                                .then((userElectionsSnap) {
                              var userElections = userElectionsSnap.docs
                                  .map((election) =>
                                      Get.find<ElectionController>()
                                          .fromDocumentSnapshot(election))
                                  .toList();
                              for (var element in userElections) {
                                print(element);

                                allElections.add(element);
                              }
                              for (var election in allElections) {
                                if (election.accessCode ==
                                    _electionAccessCodeController.text) {
                                  print(
                                      "Election found ${election.accessCode}");
                                  Get.to(const CastVote(), arguments: election);
                                }
                              }
                            });
                          }
                          //print("All elections $allElections");
                        });
                      },
                      icon: const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Validate",
                        style: TextStyle(color: Colors.white, fontSize: 20.0),
                      )),
                )
              ],
            ),
            const SizedBox(
              height: 40.0,
            ),
            GestureDetector(
              onTap: () {
                Get.to(const NewVote());
              },
              child: const ActionBox(
                action: "Create Election",
                description: "Create a new vote",
                image: Icons.how_to_vote,
              ),
            ),
            InkWell(
              onTap: () => Get.to(const UserElections()),
              child: const ActionBox(
                action: "My Elections",
                description: "Create a new vote",
                image: Icons.ballot,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
