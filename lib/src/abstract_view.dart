import 'package:flutter/material.dart';

abstract class AbstractView extends StatelessWidget {
  const AbstractView({
    super.key
  });

  AppBar buildAppBar(BuildContext context);
  Widget buildBody(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: buildBody(context),
    );
  }
}
