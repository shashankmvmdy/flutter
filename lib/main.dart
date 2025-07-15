import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(EmployeeApp());

class EmployeeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Employee List',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: EmployeeListScreen(),
    );
  }
}

class Employee {
  final int id;
  final String firstName;
  final String lastName;
  final String email;

  Employee({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
    );
  }
}

class EmployeeListScreen extends StatefulWidget {
  @override
  _EmployeeListScreenState createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  List<Employee> employees = [];
  List<Employee> filteredEmployees = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    final response = await http.get(Uri.parse('https://reqres.in/api/users?page=2'));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body)['data'];
      final loadedEmployees = data.map((json) => Employee.fromJson(json)).toList();

      setState(() {
        employees = List<Employee>.from(loadedEmployees);
        filteredEmployees = employees;
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load employees');
    }
  }

  void _filterEmployees(String query) {
    final filtered = employees.where((emp) =>
        emp.firstName.toLowerCase().contains(query.toLowerCase())).toList();

    setState(() {
      filteredEmployees = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Employees')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Search by First Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: _filterEmployees,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredEmployees.length,
                    itemBuilder: (context, index) {
                      final emp = filteredEmployees[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(child: Text(emp.id.toString())),
                          title: Text('${emp.firstName} ${emp.lastName}'),
                          subtitle: Text(emp.email),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
