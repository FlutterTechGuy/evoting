import 'package:e_voting_app/admin/add_vote_option_screen.dart';
import 'package:e_voting_app/bidings/vote_dashboard_binding.dart';
import 'package:e_voting_app/controllers/user_controller.dart';
import 'package:e_voting_app/screens/admin/vote_dashboard.dart';
import 'package:e_voting_app/widgets/candidate_box.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class AddCandidate extends StatefulWidget {
  const AddCandidate({super.key});

  @override
  _AddCandidateState createState() => _AddCandidateState();
}

class _AddCandidateState extends State<AddCandidate> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          title: Text('Add Vote Options',
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.roboto(
                  fontSize: 18.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
        ),
        SliverToBoxAdapter(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12.0, bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                  child: Text(
                      'Election Name :${Get.arguments[1].name.toString().toUpperCase()}',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.roboto(
                          fontSize: 18.0,
                          color: Colors.green,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(
                height: 10.0,
                child: Divider(),
              ),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(20.0),
          sliver: StreamBuilder(
            stream: _firestore
                .collection("users")
                .doc(Get.find<UserController>().user.id)
                .collection("elections")
                .doc(Get.arguments[0].id.toString())
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final ds = snapshot.data!.data() as Map<String, dynamic>;
                var data = ds['options'];
                return data.length < 1
                    ? const SliverToBoxAdapter(
                        child: Column(children: [
                          Icon(
                            Icons.person,
                            size: 100.0,
                          ),
                          Text('NO CANDIDATE ADDED YET',
                              style: TextStyle(
                                fontSize: 20.0,
                              )),
                          Text(
                            'Add candidates or options to your vote to finalise the process',
                            style: TextStyle(fontSize: 18.0),
                          ),
                        ]),
                      )
                    : SliverGrid(
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent:
                              MediaQuery.of(context).size.width * 0.50,
                          mainAxisSpacing: 10.0,
                          crossAxisSpacing: 10.0,
                          childAspectRatio: 1.0,
                        ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return CandidateBox(
                            candidateImgURL: data[index]['avatar'],
                            candidateName: data[index]['name'],
                            candidateDesc: data[index]['description'],
                            onTap: () {},
                          );
                        }, childCount: data.length));
              } else {
                return const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
            },
          ),
        ),
        SliverToBoxAdapter(
            child: Padding(
          padding: const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
          child: Container(
            height: 50.0,
            alignment: Alignment.bottomCenter,
            decoration:
                BoxDecoration(borderRadius: BorderRadius.circular(10.0)),
            child: ElevatedButton.icon(
                onPressed: () {
                  Get.to(const VoteDashboard(),
                      arguments: Get.arguments,
                      binding: VoteDashboardBinding());
                },
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text(
                  'Run Election',
                  style: TextStyle(fontSize: 18.0, color: Colors.white),
                )),
          ),
        )),
      ]),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Candidates',
        backgroundColor: Colors.green,
        onPressed: () {
          Get.to(const AddVoteOptionWidget(), arguments: Get.arguments);
        },
        child: const Icon(
          Icons.group_add,
        ),
      ),
    );
  }
}
