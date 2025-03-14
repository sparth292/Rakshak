import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

import 'contactsm.dart';
import 'customButton.dart';
import 'dbservices.dart';

class AddContacts extends StatefulWidget {
  const AddContacts({super.key});

  @override
  State<AddContacts> createState() => _AddContactsState();
}

class _AddContactsState extends State<AddContacts> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<TContact> contactList = [];
  int count = 0;

  Future<void> showlist() async {
    Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<TContact>> contactListFuture = databaseHelper.getContactList();
      contactListFuture.then((value) {
        setState(() {
          this.contactList = value;
          this.count = value.length;
        });
      });
    });
  }
  void deleteContact(TContact contact) async{
    int result = await databaseHelper.deleteContact(contact.id);
    if(result != 0){
      Fluttertoast.showToast(msg: "Contact deleted.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.pink.shade50,
          textColor: Colors.pinkAccent,
          fontSize: 16.0);
    }
  }
  @override
  void initState() {
    showlist();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromRGBO(188, 66, 107, 1),
        title: Center(
          child: Text('Guardians',style: GoogleFonts.cinzel(
            fontSize: 25,
            color: Colors.pink.shade50,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.bold,
          ),
          ),
        ),
      ),
      backgroundColor: Colors.white, // Set your desired background color
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(50),
          child: Column(
            children: [
              Center(
                child: CustomButton(

                  onPressed: () async {
                    bool result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ContactsPage()),
                    );
                    if (result == true) {
                      showlist();
                    }
                  }, text: "Add Trusted Contacts",
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: count,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      margin: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Colors.transparent,
                          width: 2,
                        ),
                      ),
                      elevation: 4,
                      color: Colors.pink.shade50,
                      child: ListTile(
                        title: Text(contactList[index].name),
                        trailing: IconButton(
                          onPressed: () {
                            deleteContact(contactList[index]);
                          },
                          icon: Icon(
                            Icons.delete_forever,
                            color: Colors.pinkAccent,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
class ContactsPage extends StatefulWidget {
  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<Contact> contacts = [];
  List<Contact> contactsFiltered = [];
  TextEditingController searchController = TextEditingController();
  DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    askPermissions();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String flattenPhoneNumber(String phoneStr) {
    return phoneStr.replaceAllMapped(RegExp(r'^(\+)|\D'), (Match m) {
      return m[0] == "+" ? "+" : "";
    });
  }

  void filterContacts() {
    List<Contact> _contacts = [];
    _contacts.addAll(contacts);
    if (searchController.text.isNotEmpty) {
      _contacts.retainWhere((element) {
        String searchTerm = searchController.text.toLowerCase();
        String searchTermFlatten = flattenPhoneNumber(searchTerm);
        String contactName = element.displayName.toLowerCase();
        bool nameMatch = contactName.contains(searchTerm);
        if (nameMatch) {
          return true;
        }
        if (searchTermFlatten.isEmpty) {
          return false;
        }
        return element.phones?.any((p) {
          String phoneFlattened = flattenPhoneNumber(p.number ?? "");
          return phoneFlattened.contains(searchTermFlatten);
        }) ?? false;
      });
    }
    setState(() {
      contactsFiltered = _contacts;
    });
  }

  Future<void> askPermissions() async {
    PermissionStatus permissionStatus = await getContactsPermission();
    if (permissionStatus == PermissionStatus.granted) {
      getAllContacts();
      searchController.addListener(() {
        filterContacts();
      });
    } else {
      handleInvalidPermission(permissionStatus);
    }
  }

  void handleInvalidPermission(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      // Handle denial of permission
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      // Handle permanent denial of permission
    }
  }

  Future<PermissionStatus> getContactsPermission() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      return await Permission.contacts.request();
    }
    return permission;
  }

  Future<void> getAllContacts() async {
    if (await FlutterContacts.requestPermission()) {
      List<Contact> _contacts = await FlutterContacts.getContacts(
          withProperties: true,withThumbnail: false);
      setState(() {
        contacts = _contacts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isSearching = searchController.text.isNotEmpty;
    bool listIsItemExist = contactsFiltered.isNotEmpty || contacts.isNotEmpty;
    DatabaseHelper _databaseHelper = DatabaseHelper();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes the back arrow
        backgroundColor: Color.fromRGBO(188, 66, 107, 1),
        title: Center(
          child: Text(
            'Contacts',
            style: GoogleFonts.cinzel(
              fontSize: 25,
              color: Colors.pink.shade50,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: contacts.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              autofocus: true,
              style: TextStyle(fontSize: 18, color: Colors.black),
              decoration: InputDecoration(
                hintText: "Search contacts...",
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.pinkAccent),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding:
                EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
            ),
          ),
          listIsItemExist
              ? Expanded(
            child: ListView.builder(
              itemCount: isSearching
                  ? contactsFiltered.length
                  : contacts.length,
              itemBuilder: (BuildContext context, int index) {
                Contact contact = isSearching
                    ? contactsFiltered[index]
                    : contacts[index];
                return Card(
                  margin: EdgeInsets.symmetric(
                      vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                        color: Colors.transparent, width: 2),
                  ),
                  elevation: 4,
                  color: Colors.pink.shade50,
                  child: ListTile(
                    onTap: (){
                      if(contact.phones!.length > 0){
                        final String phoneNum = contact.phones.elementAt(0).number!;
                        final String name = contact.displayName!;
                        _addContact(TContact(phoneNum, name));
                      }else{
                        Fluttertoast.showToast(msg : "oops! phone number of this contact does not exist.",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.pink.shade50,
                            textColor: Colors.pinkAccent,
                            fontSize: 16.0);
                      }
                    },
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                    title: Text(
                      contact.displayName ?? '',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    subtitle: (contact.phones?.isNotEmpty ?? false)
                        ? Text(contact.phones!.first.number ?? "No Number")
                        : null,
                    leading: (contact.photo != null)
                        ? CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage: MemoryImage(contact.photo!),
                    )
                        : CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text(
                        contact.displayName.isNotEmpty
                            ? contact.displayName[0].toUpperCase()
                            : "N/A",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
              : Center(
            child: Text("No contacts found"),
          ),
        ],
      ),
    );
  }
  void _addContact(TContact newContact) async{
    int result = await _databaseHelper.insertContact(newContact);
    if(result!=0){
      Fluttertoast.showToast(msg : "Contact added successfully.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.pink.shade50,
          textColor: Colors.pinkAccent,
          fontSize: 16.0);
    }else{
      Fluttertoast.showToast(msg : "Failed to add contacts.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.pinkAccent,
          textColor: Colors.white,
          fontSize: 16.0);
    }
    Navigator.pop(context, TContact);  // Pass the contact object back, not a bool


  }
}