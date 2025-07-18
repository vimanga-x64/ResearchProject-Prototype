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
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'package:countup/countup.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math';


class UserAccountScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;

    return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          isDarkMode ? Colors.blueGrey.shade900 : Colors.orange.shade100,
          isDarkMode ? Colors.grey.shade900 : Colors.white,
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 0.5],
      ),
    ),
    child: Scaffold(
      backgroundColor: Colors.transparent,
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
    return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          widget.isDarkMode ? Colors.blueGrey.shade900 : Colors.orange.shade100,
          widget.isDarkMode ? Colors.grey.shade900 : Colors.white,
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 0.5],
      ),
    ),
    child: Scaffold(
      backgroundColor: Colors.transparent,
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

    return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          isDarkMode ? Colors.blueGrey.shade900 : Colors.orange.shade100,
          isDarkMode ? Colors.grey.shade900 : Colors.white,
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 0.5],
      ),
    ),
    child: Scaffold(
      backgroundColor: Colors.transparent,
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDarkMode ? Colors.blueGrey.shade900 : Colors.orange.shade100,
            isDarkMode ? Colors.grey.shade900 : Colors.white,
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 0.5],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
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
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  int _totalScore = 0; // Persistent total score starting at 75
  String emotion = "neutral";
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isDarkMode = false;
  int _currentIndex = 0; // To control BottomNavigationBar selection

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _totalScore = 75;
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
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          _isDarkMode ? Colors.blueGrey.shade900 : Colors.orange.shade100,
          _isDarkMode ? Colors.grey.shade900 : Colors.white,
          Colors.transparent,
        ],
        stops: [0.0, 0.7, 1.0], // This creates a hard stop at 50%
      ),
    ),
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
                    width: 250,
                    height: 250,
                    padding: EdgeInsets.all(8),
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
                      size: 250,
                      borderColor: _isDarkMode ? Colors.blue.shade200 : Colors.blue.shade800,
                      borderWidth: 4,
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
    final userData = await _firestoreService.getUser(user.uid);
    setState(() {
      _totalScore = userData?.score ?? 75; // Default to 75 if no score exists
      _userData = {
        'score': _totalScore,
        'highestStreak': userData?.highestStreak ?? 0,
        'displayName': user.displayName,
      };
      emotion = getAvatarEmotion(_totalScore);
      _isLoading = false;
    });
  }
}

void _logout(BuildContext context) async {
  await _authService.updateUserScore(_totalScore);
  await _authService.signOut();
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => LoginScreen()),
    (route) => false,
  );
}


void _showHelp() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Help Center'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How to use this app:'),
          SizedBox(height: 10),
          Text('• Tap lessons to start learning'),
          Text('• Track progress in your profile'),
          Text('• Contact support if needed'),
          SizedBox(height: 15),
          Text('For more help:'),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Add email launch code if desired
            },
            child: Text('support@test.com'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close'),
        ),
      ],
    ),
  );
}


void _navigateToLesson(String subject) async {
  final lesson = Lesson.createSampleLesson(subject);
  
  final dynamic lessonResult = await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => LessonScreen(lesson: lesson)),
  );

  if (lessonResult != null && mounted) {
    // Safely extract values
    final int scoreGained = (lessonResult['score'] as num).toInt();
    final int lessonHighestStreak = (lessonResult['highestStreak'] as num).toInt();
    final int newTotalScore = _totalScore + scoreGained;
    final int currentHighestStreak = _userData?['highestStreak'] ?? 0;
    final int newHighestStreak = max(currentHighestStreak, lessonHighestStreak);

    setState(() {
      _totalScore = newTotalScore;
      _userData?['highestStreak'] = newHighestStreak;
      emotion = getAvatarEmotion(_totalScore);
    });

    // Single Firestore update call
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestoreService.updateUserData(
        user.uid,
        score: newTotalScore,
        highestStreak: newHighestStreak,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lesson completed! Gained $scoreGained points. '
                     'Current streak: $lessonHighestStreak'),
        duration: Duration(seconds: 3),
      ),
    );
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

  

Widget _buildLessonCard(String subject, String animationPath, Color baseColor) {
  // Define gradients for each subject
  final Gradient gradient;
  switch (subject.toLowerCase()) {
    case 'math':
      gradient = LinearGradient(
        colors: [
          baseColor.withOpacity(0.8),
          Colors.orange.shade600,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      break;
    case 'science':
      gradient = LinearGradient(
        colors: [
          baseColor.withOpacity(0.8),
          Colors.green.shade600,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      break;
    case 'history':
      gradient = LinearGradient(
        colors: [
          baseColor.withOpacity(0.8),
          Colors.purple.shade600,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      break;
    case 'english':
      gradient = LinearGradient(
        colors: [
          baseColor.withOpacity(0.8),
          Colors.blue.shade600,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      break;
    default:
      gradient = LinearGradient(
        colors: [
          baseColor.withOpacity(0.8),
          Colors.teal.shade600,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
  }

  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () => _navigateToLesson(subject),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: gradient,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              animationPath,
              width: 100,
              height: 100,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 10),
            Text(
              subject,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
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

  void _showNotifications() {
  // Implement your notifications dialog/screen
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Notifications'),
      content: Text('You have no new notifications'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    ),
  );
}

  void _confirmSignOut() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Sign Out'),
      content: Text('Are you sure you want to sign out?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            await _authService.signOut();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => LoginScreen()),
              (route) => false,
            );
          },
          child: Text(
            'Sign Out',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );
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
  extendBodyBehindAppBar: true,
  appBar: _currentIndex == 0 
    ? AppBar(
  backgroundColor: Colors.transparent,
  elevation: 0,
  title: Text('App_Prototype'), // Or your app name
  actions: [
    if ((_userData?['highestStreak'] ?? 0) > 0)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Tooltip(
              message: 'Your personal best streak: ${_userData?['highestStreak']}',
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.shade700.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.emoji_events, 
                        color: Colors.amber.shade200, size: 18),
                    SizedBox(width: 4),
                    Text(
                      '${_userData?['highestStreak']}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
    IconButton(
      icon: Icon(Icons.notifications),
      onPressed: () => _showNotifications(),
      tooltip: 'Help',
    ),
    IconButton(
      icon: Icon(Icons.help_outline),
      onPressed: () => _showHelp(),
      tooltip: 'Help',
    ),
    IconButton(
      icon: Icon(Icons.logout),
      onPressed: _confirmSignOut,
      tooltip: 'Sign Out',
    ),
  ],
)
    : null,
  body: IndexedStack(
    index: _currentIndex,
    children: _pages,
  ),
bottomNavigationBar: Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 10,
        spreadRadius: 2,
      ),
    ],
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    child: BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: _onItemTapped,
      backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.white,
      //backgroundColor: Colors.transparent,
      selectedItemColor: _isDarkMode ? Colors.blue.shade200 : Colors.blue.shade800,
      unselectedItemColor: _isDarkMode ? Colors.grey[500] : Colors.grey[600],
      elevation: 10,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 12),
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined, size: 24),
          activeIcon: Icon(Icons.home_rounded, size: 26),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle_outlined, size: 24),
          activeIcon: Icon(Icons.account_circle_rounded, size: 26),
          label: 'Profile',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined, size: 24),
          activeIcon: Icon(Icons.calendar_today_rounded, size: 26),
          label: 'Calendar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outlined, size: 24),
          activeIcon: Icon(Icons.people_rounded, size: 26),
          label: 'Tutors',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined, size: 24),
          activeIcon: Icon(Icons.settings_rounded, size: 26),
          label: 'Settings',
        ),
      ],
    ),
  ),
),
);

    
  }
}