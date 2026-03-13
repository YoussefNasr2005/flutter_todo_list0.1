import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;
  // --- User Info ---
  String userName = "";

  Future<void> loadName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('username') ?? "User";
    });
  }

  String get userEmail =>
      FirebaseAuth.instance.currentUser?.email ?? "No Email";

  // --- UI State ---
  String appBarTitle = "Hello Let’s organize your tasks!";
  String selectedCategory = "Home";

  // --- Category List ---
  final List<Map<String, dynamic>> categories = [
    {
      "icon": Icons.wb_sunny_outlined,
      "color": Colors.amber,
      "name": "My Day",
      "count": 0
    },
    {
      "icon": Icons.star_border,
      "color": Colors.redAccent,
      "name": "Important",
      "count": 0
    },
    {
      "icon": Icons.check_box_outlined,
      "color": Colors.lightGreen,
      "name": "Tasks",
      "count": 0
    },
    {
      "icon": Icons.note_alt_outlined,
      "color": Colors.blue,
      "name": "Planned",
      "count": 0
    },
    {
      "icon": Icons.person_2_outlined,
      "color": Colors.blue,
      "name": "Assigned",
      "count": 0
    },
  ];

  // --- Tasks stored locally by category ---
  Map<String, List<Map<String, dynamic>>> categoryTasks = {
    "Home": [],
    "My Day": [],
    "Important": [],
    "Tasks": [],
    "Planned": [],
    "Assigned": [],
  };

  // --- Search ---
  List<Map<String, dynamic>> filteredCategories = [];
  TextEditingController searchController = TextEditingController();

  // --- New Card Input ---
  String? newCardTitle;
  String? newCardDescription;
  String newCardDate = DateTime.now().toString();

  @override
  void initState() {
    super.initState();
    filteredCategories = categories;
    searchController.addListener(filterCategories);
    fetchCards();
    loadName();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void filterCategories() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredCategories = categories.where((cat) {
        final name = cat['name'].toString().toLowerCase();
        return name.contains(query);
      }).toList();
    });
  }

  String formatDate(String? dateString) {
    if (dateString == null) return '';
    final date = DateTime.tryParse(dateString);
    if (date == null) return '';
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  // --- Firebase Functions ---
  Future<String?> addNewCard() async {
    if (user == null) return null;

    try {
      final docRef = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('categories')
          .add({
        'title': newCardTitle ?? "New Task",
        'description': newCardDescription ?? "Details",
        'date': newCardDate,
        'category': selectedCategory, // مهم عشان تعرف الكارت ينتمي لأي category
      });
      print("Card added for ${user!.email}");
      return docRef.id;
    } catch (e) {
      print("Failed to add card: $e");
      return null;
    }
  }

  Future<void> updateCard(
      String docId, String title, String description) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('categories')
        .doc(docId)
        .update({
      'title': title,
      'description': description,
    });
  }

  Future<void> deleteCard(String docId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('categories')
        .doc(docId)
        .delete();
  }

  Future<void> fetchCards() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // نهيئ الـ categoryTasks لكل كاتيجوري قبل الجلب
      for (var cat in categories) {
        categoryTasks[cat['name']] = [];
      }

      // نجيب كل الكروت للمستخدم
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('categories')
          .get();

      // نحط كل كارت في الـ categoryTasks المناسب
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final catName = data['category'] ??
            "Tasks"; // استخدم "category" أو "Tasks" افتراضياً
        categoryTasks[catName]?.add({
          'docId': doc.id,
          'title': data['title'] ?? '',
          'description': data['description'] ?? '',
          'date': data['date'] ?? '',
        });
      }

      // تحديث الـ count لكل كاتيجوري
      for (var cat in categories) {
        cat['count'] = categoryTasks[cat['name']]!.length;
      }

      setState(() {}); // عمل تحديث للشاشة
    } catch (e) {
      print("Error fetching cards: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Hello $userName,\nLet’s organize your tasks!",
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () async {
              AwesomeDialog(
                context: context,
                dialogType: DialogType.warning,
                desc: "Are you sure make logout?",
                btnOkOnPress: () async {
                  await GoogleSignIn.instance.disconnect();
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('login', (route) => false);
                },
                btnCancelOnPress: () {},
              ).show();
            },
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      drawer: buildDrawer(),
      backgroundColor:
          selectedCategory == "Home" ? Colors.brown : Colors.grey.shade400,
      floatingActionButton:
          selectedCategory == "Home" ? null : buildAddCardButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndDocked,
      body: buildTaskList(),
    );
  }

  Drawer buildDrawer() {
    return Drawer(
      backgroundColor: Colors.black,
      child: Padding(
        padding: const EdgeInsets.only(top: 50, left: 10),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage("assets/images/MyPhoto.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Text(
                      userName,
                      style: const TextStyle(color: Colors.amberAccent),
                    ),
                    subtitle: Text(userEmail,
                        style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            buildSearchField(),
            Expanded(
              child: ListView.builder(
                itemCount: filteredCategories.length,
                itemBuilder: (context, index) {
                  final cat = filteredCategories[index];
                  return ListTile(
                    leading: Icon(cat['icon'], color: cat['color']),
                    title: Text(cat['name'],
                        style: const TextStyle(color: Colors.white)),
                    trailing: Text('${cat['count']}',
                        style: const TextStyle(color: Colors.white)),
                    onTap: () {
                      setState(() {
                        selectedCategory = cat['name'];
                        appBarTitle = cat['name'];
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  SizedBox buildSearchField() {
    return SizedBox(
      height: 40,
      child: Padding(
        padding: const EdgeInsets.only(right: 10),
        child: TextField(
          controller: searchController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Search',
            labelStyle: const TextStyle(color: Colors.white60),
            prefixIcon: const Icon(Icons.search, color: Colors.white),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            fillColor: Colors.black54,
          ),
        ),
      ),
    );
  }

  FloatingActionButton buildAddCardButton() {
    return FloatingActionButton(
      onPressed: () async {
        final docId = await addNewCard();
        if (docId == null) return;

        setState(() {
          categoryTasks[selectedCategory]?.add({
            'docId': docId,
            'title': newCardTitle ?? "New Task",
            'description': newCardDescription ?? "Details",
            'date': newCardDate,
          });

          final index =
              categories.indexWhere((cat) => cat['name'] == selectedCategory);
          if (index != -1) {
            categories[index]['count'] =
                categoryTasks[selectedCategory]!.length;
          }
        });
      },
      backgroundColor: Colors.black,
      child:
          const Text('+', style: TextStyle(color: Colors.white, fontSize: 35)),
    );
  }

  Widget buildTaskList() {
    final tasks = categoryTasks[selectedCategory];
    if (selectedCategory == "Home" && user != null) {
      return const Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Select a category to get started. ',
              style: TextStyle(color: Colors.white70, fontSize: 20),
            ),
            Icon(
              Icons.menu,
              color: Colors.white70,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: tasks!.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Card(
          color: Colors.brown.shade400,
          elevation: 20,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(
              color: Colors.black,
              width: 3,
            ),
          ),
          child: ListTile(
            leading: Text(formatDate(task['date'])),
            title: Text(task['title'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(task['description'] ?? ''),
            onTap: () => editTaskDialog(task),
            trailing: IconButton(
              icon: Icon(
                Icons.delete,
                color: Colors.brown.shade700,
              ),
              onPressed: () => confirmDeleteTask(task, index),
            ),
          ),
        );
      },
    );
  }

  void editTaskDialog(Map<String, dynamic> task) {
    final titleController = TextEditingController(text: task['title']);
    final descController = TextEditingController(text: task['description']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Edit Task',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(fontSize: 15),
            ),
            TextField(
              controller: descController,
              style: const TextStyle(fontSize: 15),
              keyboardType: TextInputType.multiline,
              maxLines: null,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (task['docId'] != null) {
                await updateCard(
                    task['docId']!, titleController.text, descController.text);
              }
              setState(() {
                task['title'] = titleController.text;
                task['description'] = descController.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void confirmDeleteTask(Map<String, dynamic> task, int index) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      desc: "Are you sure you want to delete this card?",
      btnOkOnPress: () async {
        if (task['docId'] != null) await deleteCard(task['docId']!);

        setState(() {
          categoryTasks[selectedCategory]!.removeAt(index);

          final catIndex =
              categories.indexWhere((cat) => cat['name'] == selectedCategory);
          if (catIndex != -1) {
            categories[catIndex]['count'] =
                categoryTasks[selectedCategory]!.length;
          }
        });
      },
      btnCancelOnPress: () {},
    ).show();
  }
}
