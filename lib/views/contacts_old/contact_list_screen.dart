import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/contact_view_model.dart';
import 'edit_contact_screen.dart';
import '../sidebar_menu.dart'; // <-- import your new widget

class ContactListScreen extends StatefulWidget {
  const ContactListScreen({Key? key}) : super(key: key);

  @override
  _ContactListScreenState createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ContactViewModel>(context, listen: false).fetchContacts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phonebook')),
      drawer: const SidebarMenu(), // <-- use it here
      body: Consumer<ContactViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.contacts.isEmpty) {
            return const Center(child: Text('No contacts found.'));
          }
          return ListView.builder(
            itemCount: viewModel.contacts.length,
            itemBuilder: (context, i) {
              final c = viewModel.contacts[i];
              return ListTile(
                title: Text(c.name),
                subtitle: Text(c.phone),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => viewModel.deleteContact(c.id!),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditContactScreen(contact: c),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/addContact'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
