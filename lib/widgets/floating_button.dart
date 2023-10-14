import 'package:e_voting_app/config/styles.dart';
import 'package:flutter/material.dart';

class FloatingButton extends StatefulWidget {
  const FloatingButton({super.key});

  @override
  _FloatingButtonState createState() => _FloatingButtonState();
}

class _FloatingButtonState extends State<FloatingButton> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => print('Floating Action button pressed'),
      child: Container(
        decoration: BoxStyles.gradientBox,
        child: IconButton(
            icon: const Icon(Icons.how_to_vote_rounded),
            onPressed: () => print('How to vote')),
      ),
    );
  }
}
