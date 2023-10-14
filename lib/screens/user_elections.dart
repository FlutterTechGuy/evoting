import 'package:e_voting_app/controllers/election_controller.dart';
import 'package:e_voting_app/controllers/user_controller.dart';
import 'package:e_voting_app/screens/admin/vote_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class UserElections extends StatelessWidget {
  const UserElections({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(UserController());
    return Scaffold(
      body: StreamBuilder(
        stream: _firestore
            .collection("users")
            .doc(Get.find<UserController>().user.id)
            .snapshots(),
        // ignore: missing_return
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final ds = snapshot.data!.data() as Map<String, dynamic>;
            var elections = ds['owned_elections'];
            if (elections.length < 1) {
              return const Center(
                child: ListTile(
                  leading: Icon(
                    Icons.warning_amber_outlined,
                    color: Colors.red,
                  ),
                  title: Text("Sorry you dont have any election"),
                  subtitle: Text("Your elections will be displayed there"),
                ),
              );
            }
            // 9703431990
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  title: Text(
                    "OWNED ELECTIONS",
                    style: GoogleFonts.roboto(
                        fontSize: 18.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 30.0,
                  ),
                ),
                SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                  return StreamBuilder(
                    stream: _firestore
                        .collection("users")
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .collection("elections")
                        .doc(elections[index])
                        .snapshots(),
                    // ignore: missing_return
                    builder: (context, snap) {
                      if (snap.hasData) {
                        return GestureDetector(
                          onTap: () {
                            Get.to(const VoteDashboard(),
                                arguments: [snap.data!.data()]);
                          },
                          child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 20.0, right: 20.0),
                              child: Container(
                                  height: 70.0,
                                  margin: const EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.0),
                                    color: Colors.green[100]!,
                                  ),
                                  child: ListTile(
                                    trailing: const Icon(Icons.chevron_right),
                                    title: Text(ds['name'] ?? "Name"),
                                    subtitle: Column(
                                      children: [
                                        Text(
                                          ds['description'] ?? '',
                                        ),
                                        Text(
                                          ds['endDate'] ?? '',
                                        )
                                      ],
                                    ),
                                    isThreeLine: true,
                                    onTap: () {
                                      Get.to(const VoteDashboard(), arguments: [
                                        Get.find<ElectionController>()
                                            .fromDocumentSnapshot(snap.data!)
                                      ]);
                                    },
                                  ))),
                        );
                      } else {
                        return const Center(child: Text("Loading..."));
                      }
                    },
                  );
                }, childCount: elections.length))
              ],
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Text("Loading..."));
          }
          return const Center(child: Text("Something went wrong..."));
        },
      ),
    );
  }
}
