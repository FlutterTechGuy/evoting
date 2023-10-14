import 'package:e_voting_app/controllers/election_controller.dart';
import 'package:e_voting_app/controllers/user_controller.dart';
import 'package:e_voting_app/models/election_model.dart';
import 'package:e_voting_app/screens/realtime_result.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CastVote extends StatefulWidget {
  const CastVote({super.key});

  @override
  _CastVoteState createState() => _CastVoteState();
}

class _CastVoteState extends State<CastVote> {
  @override
  Widget build(BuildContext context) {
    List options = Get.arguments.options;
    Object? target;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cast your vote"),
      ),
      body: Column(
        children: [
          const Text("Election Detail"),
          ListTile(
            title: Text('Name: ${Get.arguments.name.toString()}'),
            subtitle: Text(Get.arguments.description.toString()),
            isThreeLine: true,
            trailing: Column(
              children: [
                Text(
                    '${DateFormat().add_MMMd().format(DateTime.parse(Get.arguments.startDate))} - ${DateFormat().add_MMMd().format(DateTime.parse(Get.arguments.endDate))}')
              ],
            ),
          ),
          Text(
            "Choose one of the following candidates",
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(fontSize: 18, color: Colors.green),
          ),
          const SizedBox(
            height: 10,
          ),
          ...List.generate(options.length, (index) {
            final dt = options[index];
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                onTap: () {
                  Get.dialog(
                    AlertDialog(
                      title: const ListTile(
                        leading: Icon(
                          Icons.warning,
                          size: 36.0,
                          color: Colors.yellow,
                        ),
                        title: Text("CONFIRM YOUR CHOICE PLEASE"),
                        subtitle: Text(
                            "Notice that you cannot change after confirmation"),
                      ),
                      content: Container(
                        height: 230.0,
                        // width: 250.0,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.green[300]!,
                                ])),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 10.0,
                                  ),
                                  child: CircleAvatar(
                                      radius: 60.0,
                                      backgroundImage: NetworkImage(
                                          options[index]["avatar"])),
                                ),
                              ),
                              const SizedBox(height: 15.0),
                              Text(options[index]["name"],
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 5.0),
                              Text(
                                options[index]["description"],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10.0),
                              Text(
                                "${options[index]["count"].toString()} VOTES COUNT",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10.0),
                            ],
                          ),
                        ),
                      ),
                      actions: <Widget>[
                        ElevatedButton(
                          child: const Text("No"),
                          onPressed: () {
                            Get.back();
                          },
                        ),
                        ElevatedButton.icon(
                            onPressed: () {
                              FirebaseFirestore firestore =
                                  FirebaseFirestore.instance;
                              List<ElectionModel> allElections = [];
                              var usersQuerySnap =
                                  firestore.collection("users").get();
                              usersQuerySnap.then((usersQuery) {
                                var allUsers = usersQuery.docs
                                    .map((user) => Get.find<UserController>()
                                        .fromDocumentSnapshot(user))
                                    .toList();

                                for (var user in allUsers) {
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
                                      if (element.accessCode ==
                                          Get.arguments.accessCode) {
                                        setState(() {
                                          target = element;
                                        });
                                        firestore
                                            .collection("users")
                                            .doc(element.owner)
                                            .collection("elections")
                                            .doc(element.id)
                                            .update({
                                          "options": FieldValue.arrayRemove([
                                            {
                                              "avatar": element.options![index]
                                                  ['avatar'],
                                              "name": element.options![index]
                                                  ['name'],
                                              "description":
                                                  element.options![index]
                                                      ['description'],
                                              "count": element.options![index]
                                                  ['count']
                                            }
                                          ])
                                        });

                                        element.options![index]['count']++;
                                        var updatedOption =
                                            element.options![index];

                                        firestore
                                            .collection("users")
                                            .doc(element.owner)
                                            .collection("elections")
                                            .doc(element.id)
                                            .update({
                                          "options": FieldValue.arrayUnion([
                                            {
                                              "avatar": updatedOption['avatar'],
                                              "name": updatedOption['name'],
                                              "description":
                                                  updatedOption['description'],
                                              "count": updatedOption['count']
                                            }
                                          ])
                                        }).then((value) {
                                          Get.to(const RealtimeResult(),
                                              arguments: target);
                                        });
                                      }
                                    }
                                  });
                                }
                                //print("All elections $allElections");
                              });
                            },
                            icon: const Icon(Icons.how_to_vote),
                            label: const Text("Confirm"))
                      ],
                    ),
                    barrierDismissible: true,
                    arguments: Get.arguments,
                  );
                },
                leading: dt['avatar'] == null
                    ? null
                    : CircleAvatar(
                        backgroundColor: Colors.grey[100],
                        backgroundImage: NetworkImage(dt['avatar']),
                      ),
                tileColor: Colors.green[100],
                title: Text(dt['name']),
              ),
            );
          })
        ],
      ),

      // body: CustomScrollView(
      //   slivers: [
      //     SliverAppBar(
      //       title: Text(
      //         "CAST YOUR VOTE",
      //         style: GoogleFonts.yanoneKaffeesatz(
      //             fontSize: 25.0,
      //             color: Colors.white,
      //             fontWeight: FontWeight.bold),
      //       ),
      //     ),

      //     const SliverToBoxAdapter(
      //       child: Divider(),
      //     ),
      //     SliverPadding(
      //         padding: const EdgeInsets.only(top: 20.0),
      //         sliver: SliverToBoxAdapter(
      //             child: Center(
      //           child: Text(
      //             Get.arguments.name.toString().toUpperCase(),
      //             style: GoogleFonts.yanoneKaffeesatz(
      //                 fontSize: 28.0,
      //                 color: Colors.green,
      //                 fontWeight: FontWeight.bold),
      //           ),
      //         ))),
      //     SliverToBoxAdapter(
      //         child: Center(
      //       child: Text(
      //         Get.arguments.description.toString(),
      //         style: GoogleFonts.yanoneKaffeesatz(
      //             fontSize: 20.0,
      //             color: Colors.grey,
      //             fontWeight: FontWeight.bold),
      //       ),
      //     )),
      //     const SliverToBoxAdapter(
      //       child: SizedBox(height: 40.0),
      //     ),
      //     // SliverPadding(
      //     //   padding: const EdgeInsets.only(left: 30.0, right: 30.0),
      //     //   sliver: SliverToBoxAdapter(
      //     //     child: Text(
      //     //         "You are required to choose only one option and confirm your choice",
      //     //         style: TextStyle(color: Colors.grey, fontSize: 18.0)),
      //     //   ),
      //     // ),
      //     SliverList(
      //       delegate: SliverChildBuilderDelegate(
      //         (BuildContext context, int index) {
      //           return Padding(
      //               padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      //               child: Container(
      //                   height: 70.0,
      //                   margin: const EdgeInsets.all(5.0),
      //                   decoration: BoxDecoration(
      //                       borderRadius: BorderRadius.circular(12.0),
      //                       gradient: LinearGradient(
      //                         end: Alignment.bottomRight,
      //                         colors: [
      //                           Colors.green[200]!,
      //                         ],
      //                       )),
      //                   child: ListTile(
      //                     leading: CircleAvatar(
      //                         radius: 30.0,
      //                         backgroundImage:
      //                             NetworkImage(options[index]["avatar"])),
      //                     trailing: Text(
      //                       "${options[index]["count"].toString()} Votes",
      //                       style: const TextStyle(
      //                           color: Colors.green,
      //                           fontSize: 20.0,
      //                           fontWeight: FontWeight.bold),
      //                     ),
      //                     title: Text(
      //                         options[index]["name"].toString().toUpperCase()),
      //                     subtitle: Text(options[index]["description"]),
      //                     onTap: () {
      //                       Get.dialog(
      //                         AlertDialog(
      //                           title: const ListTile(
      //                             leading: Icon(
      //                               Icons.warning,
      //                               size: 36.0,
      //                               color: Colors.yellow,
      //                             ),
      //                             title: Text("CONFIRM YOUR CHOICE PLEASE"),
      //                             subtitle: Text(
      //                                 "Notice that you cannot change after confirmation"),
      //                           ),
      //                           content: Container(
      //                             height: 230.0,
      //                             // width: 250.0,
      //                             decoration: BoxDecoration(
      //                                 borderRadius: BorderRadius.circular(10.0),
      //                                 gradient: LinearGradient(
      //                                     begin: Alignment.topLeft,
      //                                     end: Alignment.bottomRight,
      //                                     colors: [
      //                                       Colors.green[300]!,
      //                                     ])),
      //                             child: Center(
      //                               child: Column(
      //                                 mainAxisAlignment:
      //                                     MainAxisAlignment.center,
      //                                 crossAxisAlignment:
      //                                     CrossAxisAlignment.center,
      //                                 children: [
      //                                   Center(
      //                                     child: Padding(
      //                                       padding: const EdgeInsets.only(
      //                                         top: 10.0,
      //                                       ),
      //                                       child: CircleAvatar(
      //                                           radius: 60.0,
      //                                           backgroundImage: NetworkImage(
      //                                               options[index]["avatar"])),
      //                                     ),
      //                                   ),
      //                                   const SizedBox(height: 15.0),
      //                                   Text(options[index]["name"],
      //                                       style: const TextStyle(
      //                                           color: Colors.white,
      //                                           fontSize: 20.0,
      //                                           fontWeight: FontWeight.bold)),
      //                                   const SizedBox(height: 5.0),
      //                                   Text(
      //                                     options[index]["description"],
      //                                     maxLines: 2,
      //                                     overflow: TextOverflow.ellipsis,
      //                                   ),
      //                                   const SizedBox(height: 10.0),
      //                                   Text(
      //                                     "${options[index]["count"].toString()} VOTES COUNT",
      //                                     maxLines: 2,
      //                                     overflow: TextOverflow.ellipsis,
      //                                     style: const TextStyle(
      //                                         color: Colors.white54,
      //                                         fontSize: 20.0,
      //                                         fontWeight: FontWeight.bold),
      //                                   ),
      //                                   const SizedBox(height: 10.0),
      //                                 ],
      //                               ),
      //                             ),
      //                           ),
      //                           actions: <Widget>[
      //                             ElevatedButton(
      //                               child: const Text("No"),
      //                               onPressed: () {
      //                                 Get.back();
      //                               },
      //                             ),
      //                             ElevatedButton.icon(
      //                                 onPressed: () {
      //                                   FirebaseFirestore firestore =
      //                                       FirebaseFirestore.instance;
      //                                   List<ElectionModel> allElections = [];
      //                                   var usersQuerySnap =
      //                                       firestore.collection("users").get();
      //                                   usersQuerySnap.then((usersQuery) {
      //                                     var allUsers = usersQuery.docs
      //                                         .map((user) =>
      //                                             Get.find<UserController>()
      //                                                 .fromDocumentSnapshot(
      //                                                     user))
      //                                         .toList();

      //                                     for (var user in allUsers) {
      //                                       firestore
      //                                           .collection("users")
      //                                           .doc(user.id)
      //                                           .collection("elections")
      //                                           .get()
      //                                           .then((userElectionsSnap) {
      //                                         var userElections = userElectionsSnap
      //                                             .docs
      //                                             .map((election) => Get.find<
      //                                                     ElectionController>()
      //                                                 .fromDocumentSnapshot(
      //                                                     election))
      //                                             .toList();
      //                                         for (var element
      //                                             in userElections) {
      //                                           if (element.accessCode ==
      //                                               Get.arguments.accessCode) {
      //                                             setState(() {
      //                                               target = element;
      //                                             });
      //                                             firestore
      //                                                 .collection("users")
      //                                                 .doc(element.owner)
      //                                                 .collection("elections")
      //                                                 .doc(element.id)
      //                                                 .update({
      //                                               "options":
      //                                                   FieldValue.arrayRemove([
      //                                                 {
      //                                                   "avatar": element
      //                                                           .options![index]
      //                                                       ['avatar'],
      //                                                   "name": element
      //                                                           .options![index]
      //                                                       ['name'],
      //                                                   "description": element
      //                                                           .options![index]
      //                                                       ['description'],
      //                                                   "count": element
      //                                                           .options![index]
      //                                                       ['count']
      //                                                 }
      //                                               ])
      //                                             });

      //                                             element.options![index]
      //                                                 ['count']++;
      //                                             var updatedOption =
      //                                                 element.options![index];

      //                                             firestore
      //                                                 .collection("users")
      //                                                 .doc(element.owner)
      //                                                 .collection("elections")
      //                                                 .doc(element.id)
      //                                                 .update({
      //                                               "options":
      //                                                   FieldValue.arrayUnion([
      //                                                 {
      //                                                   "avatar": updatedOption[
      //                                                       'avatar'],
      //                                                   "name": updatedOption[
      //                                                       'name'],
      //                                                   "description":
      //                                                       updatedOption[
      //                                                           'description'],
      //                                                   "count": updatedOption[
      //                                                       'count']
      //                                                 }
      //                                               ])
      //                                             }).then((value) {
      //                                               Get.to(
      //                                                   const RealtimeResult(),
      //                                                   arguments: target);
      //                                             });
      //                                           }
      //                                         }
      //                                         // allElections.forEach((election) {
      //                                         //   print(Get.arguments.name);
      //                                         //   if (election.accessCode ==
      //                                         //       Get.arguments.accessCode) {
      //                                         //   } else {
      //                                         //     print("NOT FOUND YET");
      //                                         //   }
      //                                         // });
      //                                       });
      //                                     }
      //                                     //print("All elections $allElections");
      //                                   });
      //                                 },
      //                                 icon: const Icon(Icons.how_to_vote),
      //                                 label: const Text("Confirm"))
      //                           ],
      //                         ),
      //                         barrierDismissible: true,
      //                         arguments: Get.arguments,
      //                       );
      //                     },
      //                   )));
      //         },
      //         childCount: options.length,
      //       ),
      //     ),
      //   ],
      // ),
    );
  }
}
