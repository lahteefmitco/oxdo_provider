import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:oxdo_provider/db/database_helper.dart';
import 'package:oxdo_provider/models/person/person.dart';
import 'package:oxdo_provider/models/save_edit_mode/save_edit_mode.dart';
import 'package:oxdo_provider/provider/person_model.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseHelper.initDatabase();

  runApp(
    ChangeNotifierProvider(
      create: (context) => PersonModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter provider',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _ageFocus = FocusNode();

// Initialize person list
  List<Person> _personList = [];

  SaveEditMode _saveEditMode = SaveEditMode.save;

  // Only for updating
  Person? _personToUpdate;

  @override
  Widget build(BuildContext context) {
    return Consumer<PersonModel>(
      
      builder: (BuildContext context, PersonModel value, Widget? child) {
       
        _personList = value.personList;
        _saveEditMode = value.saveEditMode;
        _personToUpdate = value.personToUpdate;

        if (_personToUpdate != null) {
          _nameController.text = _personToUpdate!.name;
          _ageController.text = _personToUpdate!.age.toString();
        }

        return Scaffold(
          appBar: AppBar(
            title: AppBar(
              title: const Text("Provider"),
            ),
          ),
          // body
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // name field
                  TextField(
                    controller: _nameController,
                    focusNode: _nameFocusNode,
                    decoration: const InputDecoration(
                      label: Text("Name"),
                      hintText: "Enter name",
                      hintStyle: TextStyle(color: Colors.black38),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),

                  // age field
                  TextField(
                    controller: _ageController,
                    focusNode: _ageFocus,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("Age"),
                      hintText: "Enter age",
                      hintStyle: TextStyle(color: Colors.black38),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(
                    height: 8,
                  ),

                  // save or edit buttton
                  ElevatedButton(
                    onPressed: () async {
                      if (_saveEditMode == SaveEditMode.save) {
                        // To save
                        final personToSave = Person(
                          name: _nameController.text.trim(),
                          age: int.tryParse(_ageController.text.trim()) ?? 0,
                        );

                        await context
                            .read<PersonModel>()
                            .insertPerson(personToSave);
                        _nameController.clear();
                        _ageController.clear();

                        _unFocusAllFocusNode();
                      } else {
                        // To update
                        final personToUpdate = Person(
                          id: _personToUpdate?.id,
                          name: _nameController.text.trim(),
                          age: int.tryParse(_ageController.text.trim()) ?? 0,
                        );

                        await context
                            .read<PersonModel>()
                            .updatePerson(personToUpdate);
                        _nameController.clear();
                        _ageController.clear();
                        _unFocusAllFocusNode();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _saveEditMode == SaveEditMode.save
                          ? Colors.green
                          : Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                        _saveEditMode == SaveEditMode.save ? "Save" : "Update"),
                  ),
                  const SizedBox(
                    height: 8,
                  ),

                  // person list view
                  Expanded(
                    child: ListView.separated(
                      itemBuilder: (context, index) {
                        final person = _personList[index];

                        return Card(
                          child: ListTile(
                            title: Text("Name:- ${person.name}"),
                            subtitle: Text("Age:- ${person.age}"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    // take data to update
                                    context
                                        .read<PersonModel>()
                                        .bringPersonToUpdate(person);
                                  },
                                  icon: const Icon(Icons.edit),
                                ),
                                IconButton(
                                  onPressed: () {
                                    // delete data
                                    if (person.id != null) {
                                      context
                                          .read<PersonModel>()
                                          .deletePerson(person.id!);
                                    }
                                  },
                                  color: Colors.red,
                                  icon: const Icon(Icons.delete),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const Divider();
                      },
                      itemCount: _personList.length,
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // un focus text fields,  hide keyboard
  void _unFocusAllFocusNode() {
    _nameFocusNode.unfocus();
    _ageFocus.unfocus();
  }
}
