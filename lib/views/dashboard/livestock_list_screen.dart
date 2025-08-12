import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/livestock_viewmodel.dart';

class AllLivestockScreen extends StatefulWidget {
  @override
  State<AllLivestockScreen> createState() => _AllLivestockScreenState();
}

class _AllLivestockScreenState extends State<AllLivestockScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<LivestockViewModel>(context, listen: false).fetchLivestocks());
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<LivestockViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('All Livestock'),
        backgroundColor: Colors.green.shade700,
      ),
      body: vm.livestocks.isEmpty
          ? Center(child: Text('No livestock found'))
          : ListView.builder(
              itemCount: vm.livestocks.length,
              itemBuilder: (context, index) {
                final livestock = vm.livestocks[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(livestock.name),
                    subtitle: Text('Breed: ${livestock.breed}'),
                  ),
                );
              },
            ),
    );
  }
}
