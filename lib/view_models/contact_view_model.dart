import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/contact.dart';

class ContactViewModel extends ChangeNotifier {
  List<Contact> contacts = [];
  final supabase = Supabase.instance.client;

  // Fetch all contacts from the "contacts" table
  Future<void> fetchContacts() async {
    try {
      final data = await supabase.from('contacts').select();
      contacts = (data as List)
          .map((contactMap) => Contact.fromMap(contactMap))
          .toList();
      notifyListeners();
    } catch (error) {
      print('Error fetching contacts: $error');
    }
  }

  // Create a new contact
  Future<void> addContact(Contact contact) async {
    try {
      await supabase.from('contacts').insert(contact.toMap());
      await fetchContacts();
    } catch (error) {
      print('Error adding contact: $error');
    }
  }

  // Update an existing contact
  Future<void> updateContact(Contact contact) async {
    try {
      await supabase
          .from('contacts')
          .update(contact.toMap())
          .eq('id', contact.id!);
      await fetchContacts();
    } catch (error) {
      print('Error updating contact: $error');
    }
  }

  // Delete a contact
  Future<void> deleteContact(int id) async {
    try {
      await supabase.from('contacts').delete().eq('id', id);
      await fetchContacts();
    } catch (error) {
      print('Error deleting contact: $error');
    }
  }
}
