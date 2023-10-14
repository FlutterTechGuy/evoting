import 'dart:math';

import 'package:e_voting_app/controllers/election_controller.dart';
import 'package:e_voting_app/controllers/user_controller.dart';
import 'package:e_voting_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:charts_flutter_new/flutter.dart' as charts;
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class VoteDashboard extends StatefulWidget {
  const VoteDashboard({super.key});

  @override
  _VoteDashboardState createState() => _VoteDashboardState();
}

class _VoteDashboardState extends State<VoteDashboard> {
  @override
  Widget build(BuildContext context) {
    Color _candidateColor() {
      Random random = Random();
      List<Color> colors = [
        Colors.black,
        Colors.amberAccent,
        Colors.green,
        Colors.brown,
        Colors.deepOrangeAccent,
        Colors.lightGreenAccent,
        Colors.tealAccent,
        Colors.pinkAccent,
        Colors.yellowAccent,
        Colors.red,
        Colors.purple,
        Colors.lightBlue,
      ];
      int index = random.nextInt(11);
      return colors[index];
    }

    // getElection();
    // List<charts.Series<Vote, String>> _randomData() {
    //   getElection();
    //   List<Vote> voteData = List<Vote>();
    //   if (candidates != null) {
    //     for (var candidate in candidates) {
    //       if (candidate != null &&
    //           candidate['name'] != null &&
    //           candidate['count'] != null) {
    //         Vote vote =
    //             Vote(candidate['name'], candidate['count'], _candidateColor());
    //         voteData.add(vote);
    //       }
    //     }
    //   }
    //   return [
    //     charts.Series<Vote, String>(
    //         id: 'Best Framework',
    //         labelAccessorFn: (Vote votes, _) => votes.voter,
    //         colorFn: (Vote votes, _) =>
    //             charts.ColorUtil.fromDartColor(votes.voterColor),
    //         domainFn: (Vote votes, _) => votes.voter,
    //         measureFn: (Vote votes, _) => votes.voteCount,
    //         data: voteData)
    //   ];
    // }
    return Scaffold(
      body: StreamBuilder(
        stream: _firestore
            .collection("users")
            .doc(Get.find<UserController>().user.id)
            .collection("elections")
            .doc(Get.arguments[0].id.toString())
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var election = snapshot.data!.data() as Map<String, dynamic>;

            var candidates = election['options'];

            //Functions that will be in charge to generate charts data
            List<charts.Series<Vote, String>> _voteData() {
              List<Vote> voteData = [];
              if (candidates != null) {
                for (var candidate in candidates) {
                  if (candidate != null &&
                      candidate['name'] != null &&
                      candidate['count'] != null) {
                    Vote vote = Vote(candidate['name'], candidate['count'],
                        _candidateColor());
                    voteData.add(vote);
                  }
                }
              }
              return [
                charts.Series<Vote, String>(
                    id: 'Best Framework',
                    labelAccessorFn: (Vote votes, _) => votes.voter,
                    colorFn: (Vote votes, _) =>
                        charts.ColorUtil.fromDartColor(votes.voterColor),
                    domainFn: (Vote votes, _) => votes.voter,
                    measureFn: (Vote votes, _) => votes.voteCount,
                    data: voteData)
              ];
            }

            //End of chart data functions

            //Clling the function to initiate data
            List<charts.Series<dynamic, String>> seriesList = _voteData();

            //function to get the total votes count
            int totalVoteCount() {
              int totalcount = 0;
              for (var candidate in candidates) {
                totalcount += int.parse(candidate['count'].toString());
              }
              return totalcount;
            }

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  leading: IconButton(
                      icon: const Icon(Icons.dashboard),
                      onPressed: () => Get.to(const ElectChain())),
                  title: Column(
                    children: [
                      Text(
                        election['name'] != null
                            ? election['name'].toUpperCase()
                            : "Election Name...",
                        style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        election["description"],
                        style:
                            GoogleFonts.roboto(fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                        tooltip: 'Copy election access code',
                        icon: const Icon(
                          Icons.content_copy,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Get.find<ElectionController>()
                              .copyAccessCode(election["accessCode"]);
                        })
                  ],
                ),
                SliverPadding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 30.0),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            ElevatedButton.icon(
                                onPressed: () {
                                  Get.find<ElectionController>()
                                      .copyAccessCode(election["accessCode"]);
                                },
                                icon: const Icon(
                                  Icons.copy,
                                  color: Colors.white,
                                ),
                                label: const Text('Copy Access Code')),
                          ],
                        ),
                        _StatsBox(Icons.people_alt, 'CANDIDATES',
                            election["options"].length.toString()),
                        _StatsBox(Icons.how_to_vote, 'TOTAL VOTES',
                            totalVoteCount().toString())
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.40,
                        width: MediaQuery.of(context).size.width,
                        //color: Colors.black12,
                        child: charts.BarChart(
                          seriesList,
                          animate: true,
                          behaviors: [
                            charts.DatumLegend(
                              outsideJustification:
                                  charts.OutsideJustification.middleDrawArea,
                              horizontalFirst: false,
                              desiredMaxRows: 2,
                            )
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.30,
                            width: MediaQuery.of(context).size.width * 0.60,
                            // color: Colors.pinkAccent.withOpacity(.5),
                            child: charts.PieChart(
                              seriesList,
                              animate: true,
                            ),
                          ),
                          SizedBox(
                              height: MediaQuery.of(context).size.height * 0.30,
                              width: MediaQuery.of(context).size.width * 0.40,
                              //color: Colors.teal.shade200,
                              child: Padding(
                                  padding: const EdgeInsets.only(right: 10.0),
                                  child: ListView(
                                    children: const [
                                      // const Center(
                                      //   child: Text(
                                      //     'OWNER ACTIONS',
                                      //     style: TextStyle(
                                      //         color: Colors.green,
                                      //         fontSize: 18.0),
                                      //   ),
                                      // ),
                                      // ElevatedButton.icon(
                                      //     onPressed: () {},
                                      //     icon: const Icon(
                                      //       Icons.stop,
                                      //       color: Colors.red,
                                      //     ),
                                      //     label: const Text('Stop Election')),
                                      // ElevatedButton.icon(
                                      //     onPressed: () {
                                      //       Get.find<ElectionController>()
                                      //           .copyAccessCode(
                                      //               election["accessCode"]);
                                      //     },
                                      //     icon: const Icon(
                                      //       Icons.copy,
                                      //     ),
                                      //     label:
                                      //         const Text('Copy Access code')),
                                      // ElevatedButton.icon(
                                      //     onPressed: () {

                                      //     },
                                      //     icon: const Icon(
                                      //       Icons.bar_chart,
                                      //       semanticLabel: 'Chart',
                                      //     ),
                                      //     label: const Text(
                                      //         'Get Election\'s stats'))
                                    ],
                                  )))
                        ],
                      )
                    ],
                  ),
                )
              ],
            );
          } else {
            return const Text("Loaaaaaaaaaading");
          }
        },
      ),
    );
  }
}

// ignore: non_constant_identifier_names
Widget _StatsBox(IconData icon, String title, String count) {
  return Container(
    padding: const EdgeInsets.all(8.0),
    height: 100.0,
    width: 100.0,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.0),
        gradient:
            LinearGradient(colors: [Colors.green[300]!, Colors.blue[200]!])),
    child: Column(
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 12.0,
              color: Colors.black38,
              fontWeight: FontWeight.bold),
        ),
        Icon(
          icon,
          size: 40.0,
          color: Colors.green,
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Text(
            count,
            style: const TextStyle(
                fontSize: 22.0,
                color: Colors.black,
                fontWeight: FontWeight.bold),
          ),
        )
      ],
    ),
  );
}

class Vote {
  final String voter;
  final int voteCount;
  final Color voterColor;

  Vote(this.voter, this.voteCount, this.voterColor);
}
