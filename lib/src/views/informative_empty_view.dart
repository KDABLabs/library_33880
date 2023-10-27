import 'package:flutter/material.dart';

class InformativeEmptyView extends LayoutBuilder {
  InformativeEmptyView(
    String message, {
    super.key,
    bool spin = false,
  }) : super(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              padding: const EdgeInsets.all(20.0),
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      message,
                    ),
                    Visibility(
                        visible: spin,
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        )),
                  ],
                ),
              ),
            ),
          ),
        );
}
