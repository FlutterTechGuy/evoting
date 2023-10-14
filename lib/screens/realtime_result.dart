import 'package:e_voting_app/models/election_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/widgets.dart';
import 'dart:math';

import 'package:charts_flutter_new/flutter.dart' as charts;

class RealtimeResult extends StatefulWidget {
  const RealtimeResult({super.key});

  @override
  _RealtimeResultState createState() => _RealtimeResultState();
}

class _RealtimeResultState extends State<RealtimeResult> {
  ElectionModel election = Get.arguments;

  int totalVoteCount() {
    int totalcount = 0;
    for (var candidate in election.options!) {
      totalcount += candidate['count'] as int;
    }
    return totalcount;
  }

  double candidatePercentage(int totalCount, int candidateCount) {
    return (candidateCount / totalCount) * 100;
  }

  //Function that will generate a unique color for each candidate
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

  //Functions that will be in charge to generate charts data
  List<charts.Series<Vote, String>> _voteData() {
    List<Vote> voteData = [];
    if (election.options != null) {
      for (var candidate in election.options!) {
        if (candidate != null &&
            candidate['name'] != null &&
            candidate['count'] != null) {
          Vote vote =
              Vote(candidate['name'], candidate['count'], _candidateColor());
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

  @override
  Widget build(BuildContext context) {
    //Calling the function to initiate data
    List<charts.Series<dynamic, String>> seriesList = _voteData();
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(
              "REAL TIME RESULT",
              style: GoogleFonts.roboto(
                  fontSize: 25.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SliverToBoxAdapter(
              child: SizedBox(
            height: 20.0,
          )),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 140,
              child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: election.options!.map((option) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _buildCandidateResult(
                          option['avatar'],
                          option['name'],
                          candidatePercentage(
                              totalVoteCount(), option['count'])),
                    );
                  }).toList()),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 20.0,
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
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
          )
        ],
      ),
    );
  }
}

Widget _buildCandidateResult(String image, String title, double count) {
  return Container(
    padding: const EdgeInsets.all(8.0),
    height: 105.0,
    width: 110.0,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        gradient: LinearGradient(colors: [Colors.green[300]!])),
    child: Column(
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              fontSize: 18.0,
              color: Colors.black38,
              fontWeight: FontWeight.bold),
        ),
        CircleAvatar(
          radius: 35.0,
          backgroundImage: NetworkImage(image),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              "${count.toStringAsFixed(2)}%",
              style: const TextStyle(
                  fontSize: 18.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
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
