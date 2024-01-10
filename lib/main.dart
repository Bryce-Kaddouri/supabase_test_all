import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import imnage picker
import 'package:image_picker/image_picker.dart';

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
          body: Avatar(
            imageUrl: null,
            onUpload: (String url) {
              print(url);
            },
          ),
        )
        /*Scaffold(
        body: Avatar(
          imageUrl: null,
          onUpload: (url) {
            print(url);
          },
        ),
      ),*/
        );
  }
}

/*class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _usernameController = TextEditingController();
  final _websiteController = TextEditingController();

  String? _avatarUrl;
  var _loading = false;

  /// Called when image has been uploaded to Supabase storage from within Avatar widget
  Future<void> _onUpload(String imageUrl) async {
    try {
*/ /*
      final userId = supabase.auth.currentUser!.id;
*/ /*
      await supabase.from('profiles').upsert({
*/ /*
        'id': userId,
*/ /*
        'avatar_url': imageUrl,
      });
      if (mounted) {
        const SnackBar(
          content: Text('Updated your profile image!'),
        );
      }
    } on PostgrestException catch (error) {
      print('postgrest error');
      print(error);
      SnackBar(
        content: Text(error.message),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    } catch (error) {
      print('error');
      print(error);
      SnackBar(
        content: const Text('Unexpected error occurred'),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _avatarUrl = imageUrl;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
              children: [
                Avatar(
                  imageUrl: _avatarUrl,
                  onUpload: _onUpload,
                ),
              ],
            ),
    );
  }
}*/

class Avatar extends StatefulWidget {
  Avatar({
    super.key,
    required this.imageUrl,
    required this.onUpload,
  });

  String? imageUrl;
  final void Function(String) onUpload;

  @override
  _AvatarState createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.imageUrl == null || widget.imageUrl!.isEmpty)
          Container(
            width: 150,
            height: 150,
            color: Colors.grey,
            child: const Center(
              child: Text('No Image'),
            ),
          )
        else
          Image.network(
            widget.imageUrl!,
            width: 150,
            height: 150,
            fit: BoxFit.cover,
          ),
        ElevatedButton(
          onPressed: _isLoading ? null : _upload,
          child: const Text('Upload'),
        ),
      ],
    );
  }

  Future<void> _upload() async {
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 300,
      maxHeight: 300,
    );
    if (imageFile == null) {
      return;
    }
    setState(() => _isLoading = true);

    try {
      final bytes = await imageFile.readAsBytes();

      File file = File(imageFile.path);
      print(file);
      await supabase.storage
          .from('profiles')
          .uploadBinary('profiles/test1.jpg', bytes,
              fileOptions: FileOptions(
                contentType: 'image/jpg',
                upsert: true,
              ));
      String url =
          supabase.storage.from('profiles').getPublicUrl('profiles/test1.jpg');
      print(url);
      setState(() {
        widget.imageUrl = url;
      });
      /*await supabase.storage.from('profiles').upload('profiles/test.jpg', file,
          fileOptions: FileOptions(
              upsert: true,
              contentType:
                  'image/jpg'));*/ // await supabase.storage.from('profiles').uploadBinary(
      //       'profiles/test.jpeg',
      //       bytes,
      //       fileOptions: FileOptions(contentType: imageFile.mimeType),
      //     );
      /*final imageUrlResponse = await supabase.storage
          .from('profiles')
          .createSignedUrl(filePath, 60 * 60 * 24 * 365 * 10);
      widget.onUpload(imageUrlResponse);*/
    } on StorageException catch (error) {
      print('storage error');
      print(error);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (error) {
      print('error');
      print(error);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Unexpected error occurred'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }

    setState(() => _isLoading = false);
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
