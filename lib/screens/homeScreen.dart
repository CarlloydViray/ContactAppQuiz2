import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:quickalert/quickalert.dart';
import 'package:regexed_validator/regexed_validator.dart';

class homeScreen extends StatefulWidget {
  const homeScreen({super.key});

  @override
  State<homeScreen> createState() => _homeScreenState();
}

class _homeScreenState extends State<homeScreen> {
  final fname = TextEditingController();
  final lname = TextEditingController();
  final contact = TextEditingController();
  final address = TextEditingController();
  final email = TextEditingController();

  final fnameView = TextEditingController();
  final lnameView = TextEditingController();
  final contactView = TextEditingController();
  final addressView = TextEditingController();
  final emailView = TextEditingController();
  final _formkey = GlobalKey<FormState>();

  void _deleteItem(String id) async {
    await deleteData(id);
    Navigator.pop(context);
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'Success!',
        message: 'Contact deleted successfully',
        contentType: ContentType.success,
      ),
      duration: Duration(milliseconds: 2500),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          openModalBottomSheet();
        },
        backgroundColor: Color(0xff263A29),
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text('My Contacts'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            StreamBuilder(
                stream: getContacts(),
                builder: (BuildContext context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Error: ${snapshot.error.toString()}'));
                  }

                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  var data = snapshot.data!.docs;

                  return Expanded(
                    child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          var snapData = data[index];
                          var cid = snapData.id;

                          return Card(
                            child: Slidable(
                              endActionPane:
                                  ActionPane(motion: ScrollMotion(), children: [
                                SlidableAction(
                                  onPressed: (context) {
                                    openViewModalSheet(cid);
                                  },
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  icon: Icons.visibility,
                                ),
                                SlidableAction(
                                  onPressed: (context) {
                                    QuickAlert.show(
                                        context: context,
                                        type: QuickAlertType.confirm,
                                        confirmBtnText: 'Yes',
                                        title: 'Delete Contact?',
                                        onConfirmBtnTap: () {
                                          _deleteItem(cid);
                                        });
                                  },
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                ),
                              ]),
                              child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Color(0xff41644A),
                                    child: Text(snapData['firstname'][0]
                                            .toString()
                                            .toUpperCase() +
                                        snapData['lastname'][0]
                                            .toString()
                                            .toUpperCase()),
                                  ),
                                  title: Text(snapData['firstname'] +
                                      " " +
                                      snapData['lastname']),
                                  subtitle: Text(snapData['contact']),
                                  trailing: Column(
                                    children: [
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Icon(Icons.arrow_back),
                                      Text('Slide me')
                                    ],
                                  )),
                            ),
                          );
                        }),
                  );
                }),
          ],
        ),
      ),
    );
  }

  Future openModalBottomSheet() {
    return showModalBottomSheet(
        backgroundColor: Color(0xffF2E3DB),
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      key: _formkey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            'Add new contact',
                            style: TextStyle(fontSize: 21),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          //fname
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '*Required. Please enter a first name.';
                              }
                            },
                            keyboardType: TextInputType.name,
                            controller: fname,
                            decoration: const InputDecoration(
                              labelText: 'First Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          //lname
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '*Required. Please enter a last name.';
                              }
                            },
                            keyboardType: TextInputType.name,
                            controller: lname,
                            decoration: const InputDecoration(
                              labelText: 'Last Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          //contact
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '*Required. Please enter contact number.';
                              }
                              if (!validator.phone(value) ||
                                  value.length < 11) {
                                return '*Invalid Phone Number.';
                              }
                            },
                            keyboardType: TextInputType.phone,
                            controller: contact,
                            decoration: const InputDecoration(
                              labelText: 'Contact Number',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          //address
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '*Required. Please enter address.';
                              }
                            },
                            controller: address,
                            decoration: const InputDecoration(
                              labelText: 'Address',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          //email
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '*Required. Please email.';
                              }
                              if (!EmailValidator.validate(value)) {
                                return 'E*nter valid email';
                              }
                            },
                            keyboardType: TextInputType.emailAddress,
                            controller: email,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 16.0),
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Color(0xff263A29)),
                            ),
                            onPressed: () {
                              if (_formkey.currentState!.validate()) {
                                Navigator.pop(context);
                                FirebaseFirestore.instance
                                    .collection('contacts')
                                    .add({
                                  'firstname': fname.text,
                                  'lastname': lname.text,
                                  'contact': contact.text,
                                  'address': address.text,
                                  'email': email.text
                                });
                                final snackBar = SnackBar(
                                  elevation: 0,
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.transparent,
                                  content: AwesomeSnackbarContent(
                                    title: 'Success!',
                                    message: 'Contact added successfully',
                                    contentType: ContentType.success,
                                  ),
                                  duration: Duration(milliseconds: 2500),
                                );

                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(snackBar);

                                fname.clear();
                                lname.clear();
                                contact.clear();
                                address.clear();
                                email.clear();
                              }
                            },
                            child: Text('Add Contact'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  Future openViewModalSheet(String id) {
    return showModalBottomSheet(
        backgroundColor: Color(0xffF2E3DB),
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('contacts')
                  .doc(id)
                  .snapshots(),
              builder: ((context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error: ${snapshot.error.toString()}'));
                }

                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                var docSnap = snapshot.data;

                fnameView.text = docSnap!['firstname'];
                lnameView.text = docSnap['lastname'];
                contactView.text = docSnap['contact'];
                addressView.text = docSnap['address'];
                emailView.text = docSnap['email'];

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View Contact',
                              style: TextStyle(fontSize: 20),
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            TextField(
                              readOnly: true,
                              controller: fnameView,
                              decoration: const InputDecoration(
                                labelText: 'First Name',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            TextField(
                              readOnly: true,
                              controller: lnameView,
                              decoration: const InputDecoration(
                                labelText: 'Last Name',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            TextField(
                              readOnly: true,
                              controller: contactView,
                              decoration: const InputDecoration(
                                labelText: 'Contact Number',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            TextField(
                              readOnly: true,
                              controller: addressView,
                              decoration: const InputDecoration(
                                labelText: 'Address',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            TextField(
                              readOnly: true,
                              controller: emailView,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }));
        });
  }
}

Stream<QuerySnapshot> getContacts() {
  return FirebaseFirestore.instance.collection('contacts').snapshots();
}

Future<void> deleteData(String id) async {
  FirebaseFirestore.instance.collection('contacts').doc(id).delete();
}
