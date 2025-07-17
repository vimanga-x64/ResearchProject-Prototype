// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/avatar_widget.dart';
import '../utils/avatar_logic.dart';
import '../models/lesson_model.dart';
import 'package:app_prototype/widgets/lesson_card.dart' hide LessonScreen;
import 'lesson_screen.dart';
import 'login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:lottie/lottie.dart';

class UserAccountScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: user?.photoURL != null 
                        ? NetworkImage(user!.photoURL!) 
                        : null,
                    child: user?.photoURL == null
                        ? Icon(Icons.person, size: 50)
                        : null,
                  ),
                  SizedBox(height: 16),
                  Text(
                    user?.displayName ?? 'No Name',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user?.email ?? 'No Email',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
            _buildAccountItem(
              icon: Icons.edit,
              title: 'Edit Profile',
              onTap: () {},
            ),
            _buildAccountItem(
              icon: Icons.history,
              title: 'Learning History',
              onTap: () {},
            ),
            _buildAccountItem(
              icon: Icons.settings,
              title: 'Account Settings',
              onTap: () {},
            ),
            Spacer(),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                    (route) => false,
                  );
                },
                icon: Icon(Icons.logout),
                label: Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const SettingsScreen({
    Key? key,
    required this.isDarkMode,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _currentDarkMode;

  @override
  void initState() {
    super.initState();
    _currentDarkMode = widget.isDarkMode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Dark Mode'),
            value: _currentDarkMode,
            onChanged: (value) {
              setState(() {
                _currentDarkMode = value;
              });
              widget.onThemeChanged(value);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(value ? 'Dark mode enabled' : 'Light mode enabled')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: isDarkMode ? Colors.grey.shade900 : Colors.blue.shade50,
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _selectedDate,
              selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDate = selectedDay;
                });
              },
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blue.shade400,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.blue.shade700,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                Text(
                  'Upcoming Sessions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                _buildSessionItem(
                  subject: 'Mathematics',
                  time: '10:00 AM - 11:30 AM',
                  tutor: 'Dr. Smith',
                ),
                _buildSessionItem(
                  subject: 'English Literature',
                  time: '2:00 PM - 3:30 PM',
                  tutor: 'Prof. Johnson',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionItem({
    required String subject,
    required String time,
    required String tutor,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subject,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('Time: $time'),
            Text('Tutor: $tutor'),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {},
                  child: Text('Reschedule'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Join Session'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PersonalTutorsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> tutors = [
    {
      'name': 'Dr. Sarah Johnson',
      'subject': 'Mathematics',
      'rating': 4.9,
      'image': 'assets/tutor1.jpg',
    },
    {
      'name': 'Prof. Michael Chen',
      'subject': 'Physics',
      'rating': 4.7,
      'image': 'assets/tutor2.jpg',
    },
    {
      'name': 'Ms. Emily Wilson',
      'subject': 'English Literature',
      'rating': 4.8,
      'image': 'assets/tutor3.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Tutors'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: tutors.length,
        itemBuilder: (context, index) {
          final tutor = tutors[index];
          return Card(
            margin: EdgeInsets.only(bottom: 16),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage(tutor['image']),
              ),
              title: Text(
                tutor['name'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tutor['subject']),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(tutor['rating'].toString()),
                    ],
                  ),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () {},
                child: Text('Schedule'),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
        tooltip: 'Find New Tutor',
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _totalScore = 75; // Persistent total score starting at 75
  String emotion = "neutral";
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isDarkMode = false;
  int _currentIndex = 0; // To control BottomNavigationBar selection

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    emotion = getAvatarEmotion(_totalScore);
    _loadUserData();

 @override
void didChangeDependencies() {
  super.didChangeDependencies();
  final appState = MyApp.of(context);
  if (appState != null) {
    setState(() {
      _isDarkMode = appState.currentThemeMode == ThemeMode.dark;
    });
  }
}
}

 Widget _buildMainHomeScreenContent(BuildContext context) {
  return Container(
    color: _isDarkMode ? Colors.black : Colors.white, // Solid background color
    child: SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Avatar and Greeting Section
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: AvatarWidget(
                      emotion: emotion,
                      size: 200,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Greeting
                  Column(
                    children: [
                      Text(
                        'Welcome back,',
                        style: TextStyle(
                          fontSize: 18,
                          color: _isDarkMode
                              ? Colors.white.withOpacity(0.9)
                              : Colors.blue.shade900.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        _userData?['displayName'] ??
                        FirebaseAuth.instance.currentUser?.displayName ??
                        'Learner',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _isDarkMode ? Colors.white : Colors.blue.shade900,
                        ),
                      ),
                      Text(
                        'Logged in as: ${_userData?['email'] ?? FirebaseAuth.instance.currentUser?.email ?? ''}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Total Score: $_totalScore',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _isDarkMode ? Colors.white : Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Score Indicator
                  _buildScoreIndicator(),
                ],
              ),
            ),
            SizedBox(height: 30),

            // Lessons Section
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Your Lessons',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _isDarkMode ? Colors.white : Colors.blue.shade900,
                    ),
                  ),
                  SizedBox(height: 20),
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    children: [
                      _buildLessonCard('Math', 'assets/animations/math.json' , Colors.orange),
                      _buildLessonCard('Science', 'assets/animations/science.json', Colors.green),
                      _buildLessonCard('History', 'assets/animations/history.json', Colors.purple),
                      _buildLessonCard('English', 'assets/animations/english.json', Colors.blue),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Load any additional user data here if needed
      setState(() {
        _isLoading = false;
      });
    }
  }

void _logout(BuildContext context) {
  FirebaseAuth.instance.signOut().then((_) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false, // This removes all previous routes
    );
  });
}


  void _navigateToLesson(String subject) async {
    print('Navigating to lesson for subject: $subject');
    final lesson = Lesson.createSampleLesson(subject); 
  
    final int? lessonScore = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (_) => LessonScreen(lesson: lesson), 
      ),
    );

    if (lessonScore != null) {
      print('Lesson completed, returned score: $lessonScore');
      // Schedule the setState to run after the current frame is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) { // Check if the widget is still mounted
          setState(() {
            print('Updating score with setState (via addPostFrameCallback)...');
            _totalScore += lessonScore; 
            emotion = getAvatarEmotion(_totalScore); 
            print('Score updated in state to: $_totalScore');
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lesson "$subject" completed! You gained: $lessonScore points. Your total score is now: $_totalScore'), 
              duration: Duration(seconds: 3),
            ),
          );
        }
      });
    } else {
      print('Lesson completed without returning a score (e.g., navigated back)');
    }
  }

  Widget _buildScoreIndicator() {
    Color scoreColor;
    if (_totalScore >= 80) {
      scoreColor = Colors.green;
    } else if (_totalScore >= 50) {
      scoreColor = Colors.orange;
    } else {
      scoreColor = Colors.red;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: scoreColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _totalScore >= 80
                ? Icons.emoji_emotions
                : _totalScore >= 50
                    ? Icons.emoji_emotions_outlined
                    : Icons.sentiment_dissatisfied,
            color: scoreColor,
          ),
          SizedBox(width: 8),
          Text(
            'Current Mood',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: scoreColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonCard(String subject, String animationPath, Color color) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    color: _isDarkMode ? Colors.grey.shade800 : Colors.white, // Card background
    child: InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () => _navigateToLesson(subject),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(_isDarkMode ? 0.2 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Lottie.asset(
                animationPath,
                width: 80, 
                height: 80, 
                fit: BoxFit.contain,
                repeat: true, // Loop the animation
              ),
            ),
            SizedBox(height: 10),
            Text(
              subject,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _isDarkMode ? Colors.white : Colors.blue.shade800,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  // Method to handle BottomNavigationBar item taps
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Define _pages directly in the build method or as a getter
    // This ensures _buildMainHomeScreenContent is rebuilt when _totalScore or _isDarkMode changes.
    final List<Widget> _pages = [
      _buildMainHomeScreenContent(context), // This will now rebuild
      UserAccountScreen(),
      CalendarScreen(),
      PersonalTutorsScreen(),
      SettingsScreen(
        isDarkMode: _isDarkMode,
        onThemeChanged: (value) async {
          setState(() => _isDarkMode = value);
          await MyApp.of(context)?.toggleTheme(value);
          // No need to force rebuild here specifically for _totalScore
          // as _buildMainHomeScreenContent will react to _isDarkMode change
        },
      ),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true, // Allow body to extend behind transparent app bar
      appBar: _currentIndex == 0 ? AppBar( // Only show app bar on the main home screen
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout,
                color: _isDarkMode ? Colors.white : Colors.blue.shade900),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ) : null, // No app bar for other screens
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue.shade800,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed, // Ensures all labels are shown
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Tutors',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}