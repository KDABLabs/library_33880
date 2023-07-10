import 'package:flutter/material.dart';

class InformativeEmptyView extends LayoutBuilder {
  InformativeEmptyView(
    String message, {
    super.key,
  }) : super(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              padding: const EdgeInsets.all(20.0),
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Center(
                child: Text(
                  message,
                ),
              ),
            ),
          ),
        );
}
