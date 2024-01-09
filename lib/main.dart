import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://xbikruujrtiezljgcnvu.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhiaWtydXVqcnRpZXpsamdjbnZ1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDQ3NTY1NjAsImV4cCI6MjAyMDMzMjU2MH0.I41G9feLcIZQxCEKsawb7Pya_D3gVcJf9_eNAb2x4Lo',
  );

  runApp(MyApp());
}

// Get a reference your Supabase client
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: AdminUserWidget(),
      ),
    );
  }
}

class StreamMethod extends StatelessWidget {
  StreamMethod({super.key});

  Stream stream = supabase.from('countries').stream(primaryKey: ['id']);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(snapshot.data[index]['name']),
              );
            },
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

class AdminUserWidget extends StatelessWidget {
  AdminUserWidget({super.key});

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  var adminSupabase = Supabase.instance.client.auth;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TextFormField(
        controller: _emailController,
        decoration: InputDecoration(
          labelText: 'Email',
        ),
      ),
      TextFormField(
        controller: _passwordController,
        decoration: InputDecoration(
          labelText: 'Password',
        ),
      ),
      ElevatedButton(
        onPressed: () async {
          /* AuthResponse response = await adminSupabase.signInWithPassword(
              email: _emailController.text, password: _passwordController.text);
          print(response);*/

          //

          try {
            var response = await supabase.auth.signInWithPassword(
              email: _emailController.text,
              password: _passwordController.text,
            );
            print(response.user);
            print(response.session);
            if (response.user != null &&
                response.user!.appMetadata['role'] == 'ADMIN') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            } else {
              var snack = SnackBar(content: Text('Not Admin'));
              ScaffoldMessenger.of(context).showSnackBar(snack);
            }
          } catch (e) {
            print(e);
            var snack = SnackBar(content: Text(e.toString()));
            ScaffoldMessenger.of(context).showSnackBar(snack);
          }
        },
        child: Text('Signin'),
      ),
    ]);
  }
}

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  final supabaseAdmin = SupabaseClient(
      'https://xbikruujrtiezljgcnvu.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhiaWtydXVqcnRpZXpsamdjbnZ1Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTcwNDc1NjU2MCwiZXhwIjoyMDIwMzMyNTYwfQ.qygMomgwZcWBv2vldVv--cxV1uYb4ZXhNJEhNvDqAI0');

  final roles = ["ADMIN", "COOKER"];

  int _selectedRole = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
            ),
          ),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
            ),
          ),
          DropdownButton(
            value: roles[_selectedRole],
            items: roles.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedRole = roles.indexOf(value.toString());
              });
            },
          ),
          ElevatedButton(
            onPressed: () async {
              // get all users
              /* final List<User> users =
                  await supabaseAdmin.auth.admin.listUsers();
              print(users);*/

              /*final res =
                  await supabaseAdmin.auth.admin.createUser(AdminUserAttributes(
                email: 'user@email.com',
                password: 'password',
                userMetadata: {'name': 'Yoda'},
              ));*/

              try {
                UserResponse res = await supabaseAdmin.auth.admin
                    .createUser(AdminUserAttributes(
                  email: _emailController.text,
                  password: _passwordController.text,
                  userMetadata: {'name': 'Yoda'},
                  appMetadata: {'role': roles[_selectedRole]},
                  emailConfirm: true,
                ));
                print(res);
                if (res.user != null) {
                  var snack = SnackBar(content: Text('User Created'));
                  ScaffoldMessenger.of(context).showSnackBar(snack);
                } else {
                  var snack = SnackBar(content: Text('User Not Created'));
                  ScaffoldMessenger.of(context).showSnackBar(snack);
                }
              } catch (e) {
                print(e);
                var snack = SnackBar(content: Text(e.toString()));
                ScaffoldMessenger.of(context).showSnackBar(snack);
              }
            },
            child: Text('Signin'),
          ),
        ],
      ),
    );
  }
}
