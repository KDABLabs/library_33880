import 'package:flutter/material.dart';
import 'package:enum_flag/enum_flag.dart';
import 'package:provider/provider.dart';

import 'abstract_view.dart';
import 'informative_empty_view.dart';
import '../constants.dart';
import '../account/result.dart';
import '../settings/settings_controller.dart';

class SearchView extends StatefulAbstractView {
  const SearchView({
    super.key,
  });

  @override
  State<SearchView> createState() {
    return _SearchViewState();
  }
}

class _SearchViewState extends AbstractViewState<SearchView> {
  int searchCriteria = SearchCriterion.All.value;
  String searchTerm = '';
  Future<List<Result>?>? task;

  final formKey = GlobalKey<FormState>();
  final TextEditingController searchTermController = TextEditingController();

  Set<String> expanded = <String>{};

  @override
  void initState() {
    super.initState();
    searchTermController.text = searchTerm;
  }

  @override
  void dispose() {
    searchTermController.dispose();
    super.dispose();
  }

  @override
  Future<void> sync(BuildContext context) async {
    final settings = context.read<SettingsController>();

    setState(() {
      searchCriteria = searchCriteria;
      searchTerm = searchTermController.text;
      task = settings.session?.search(searchTerm, searchCriteria);
    });
  }

  @override
  AppBar? buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Search'),
      actions: [
        PopupMenuButton<SearchCriterion>(
          onSelected: (searchCriterion) {
            if (searchCriteria.hasFlag(searchCriterion)) {
              searchCriteria &= ~searchCriterion.value;
            } else {
              searchCriteria |= searchCriterion.value;

              if (searchCriterion != SearchCriterion.All) {
                searchCriteria &= ~SearchCriterion.All.value;
              } else {
                searchCriteria = SearchCriterion.All.value;
              }
            }

            if (searchCriteria == 0) {
              searchCriteria = SearchCriterion.All.value;
            }
          },
          icon: const Icon(Icons.filter),
          itemBuilder: (context) {
            return <CheckedPopupMenuItem<SearchCriterion>>[
              CheckedPopupMenuItem(
                value: SearchCriterion.All,
                checked: searchCriteria.hasFlag(SearchCriterion.All),
                child: const Text("All"),
              ),
              CheckedPopupMenuItem(
                value: SearchCriterion.Title,
                checked: searchCriteria.hasFlag(SearchCriterion.Title),
                child: const Text("Title"),
              ),
              CheckedPopupMenuItem(
                value: SearchCriterion.Author,
                checked: searchCriteria.hasFlag(SearchCriterion.Author),
                child: const Text("Author"),
              ),
              CheckedPopupMenuItem(
                value: SearchCriterion.Editor,
                checked: searchCriteria.hasFlag(SearchCriterion.Editor),
                child: const Text("Editor"),
              ),
              CheckedPopupMenuItem(
                value: SearchCriterion.Subject,
                checked: searchCriteria.hasFlag(SearchCriterion.Subject),
                child: const Text("Subject"),
              ),
              CheckedPopupMenuItem(
                value: SearchCriterion.Collection,
                checked: searchCriteria.hasFlag(SearchCriterion.Collection),
                child: const Text("Collection"),
              ),
              CheckedPopupMenuItem(
                value: SearchCriterion.Serie,
                checked: searchCriteria.hasFlag(SearchCriterion.Serie),
                child: const Text("Serie"),
              ),
            ];
          },
        ),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            if (formKey.currentState!.validate()) {
              sync(context);
            }
          },
        ),
      ],
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return Column(
      children: [
        Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextFormField(
              decoration: const InputDecoration(
                hintText: 'Enter search term',
              ),
              controller: searchTermController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your search term';
                }

                return null;
              },
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder(
            future: task,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return InformativeEmptyView(snapshot.error.toString());
              }

              if (task == null ||
                  snapshot.connectionState != ConnectionState.done) {
                return InformativeEmptyView(
                  task != null ? 'Searching...' : '',
                  spin: task != null,
                );
              }

              if (!snapshot.hasData ||
                  snapshot.data == null ||
                  snapshot.data!.isEmpty) {
                return InformativeEmptyView('No results found.');
              }

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final Result result = snapshot.data![index];

                    return Card(
                      child: ListTile(
                        leading: SizedBox(
                            width: 50,
                            height: 50,
                            child: Center(
                              child: Image.network(
                                result.imageUrl.toString(),
                              ),
                            )),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              result.title,
                              textAlign: TextAlign.left,
                            ),
                            const Divider(),
                            Text(
                              result.editor,
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.right,
                            ),
                            Text(
                              result.authors.join(', '),
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                        subtitle: Visibility(
                          visible: (result.summary?.isNotEmpty ?? false) &&
                              expanded.contains(result.id),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Divider(),
                              Text(
                                result.summary ?? '',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                        trailing: Column(
                          children: [
                            Text(
                              result.availableCopies.toString(),
                              textAlign: TextAlign.right,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: result.availableCopies > 0 ? Colors.green : Colors.red),
                            ),
                            Icon(result.summary?.isNotEmpty ?? false
                                ? Icons.expand_more_outlined
                                : null),
                          ],
                        ),
                        onTap: () {
                          setState(() {
                            if (expanded.contains(result.id)) {
                              expanded.remove(result.id);
                            } else {
                              expanded.add(result.id);
                            }
                          });
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
        )
      ],
    );
  }
}
