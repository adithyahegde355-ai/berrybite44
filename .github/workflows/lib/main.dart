cat << 'EOF' > lib/main.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() {
  runApp(const BerryBiteApp());
}

class BerryBiteApp extends StatelessWidget {
  const BerryBiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BerryBite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFF8F5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC95675),
          primary: const Color(0xFFC95675),
          surface: Colors.white,
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  String _userName = "User";

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      const HomeScreen(),
      const ExploreScreen(),
      const CookScreen(),
      const SavedScreen(),
      ProfileScreen(userName: _userName, onNameChanged: (newName) {
        setState(() {
          _userName = newName;
        });
      }),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: const Color(0xFFC95675),
          unselectedItemColor: const Color(0xFF927D83),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: 'Explore'),
            BottomNavigationBarItem(icon: Icon(Icons.soup_kitchen_outlined), activeIcon: Icon(Icons.soup_kitchen), label: 'Cook'),
            BottomNavigationBarItem(icon: Icon(Icons.bookmark_outline), activeIcon: Icon(Icons.bookmark), label: 'Saved'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _trending = [];
  List<dynamic> _indianDishes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final resTrending = await http.get(Uri.parse('https://www.themealdb.com/api/json/v1/1/search.php?s=chicken'));
      final resIndian = await http.get(Uri.parse('https://www.themealdb.com/api/json/v1/1/filter.php?a=Indian'));

      setState(() {
        _trending = jsonDecode(resTrending.body)['meals'] ?? [];
        _indianDishes = jsonDecode(resIndian.body)['meals'] ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8F5),
        elevation: 0,
        title: Row(
          children: [
            const Text("🍓 ", style: TextStyle(fontSize: 24)),
            const Text("BerryBite", style: TextStyle(color: Color(0xFF49323A), fontWeight: FontWeight.bold, fontSize: 22)),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFC95675)))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text("Namaste, User 👋", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF49323A))),
                const Text("A little inspiration for every bite.", style: TextStyle(color: Color(0xFF927D83), fontSize: 14)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFF9DCE3)),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      icon: Icon(Icons.search, color: Color(0xFFC95675)),
                      hintText: "What are you craving today?",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text("Authentic Indian Cuisine 🍛", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF49323A))),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _indianDishes.length,
                    itemBuilder: (context, index) {
                      final item = _indianDishes[index];
                      return GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailScreen(mealId: item['idMeal']))),
                        child: Container(
                          width: 150,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFF9DCE3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                child: Image.network(item['strMealThumb'], height: 120, width: 150, fit: BoxFit.cover),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(item['strMeal'], maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF49323A))),
                              ),
                            ],
                          ),
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

class CookScreen extends StatefulWidget {
  const CookScreen({super.key});

  @override
  State<CookScreen> createState() => _CookScreenState();
}

class _CookScreenState extends State<CookScreen> {
  final List<String> _ingredients = ["Chicken", "Garlic", "Tomato"];
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _matchingRecipes = [];
  bool _loading = false;

  Future<void> _searchRecipes() async {
    if (_ingredients.isEmpty) return;
    setState(() => _loading = true);
    try {
      final firstIngredient = _ingredients.first.toLowerCase().replaceAll(' ', '_');
      final res = await http.get(Uri.parse('https://www.themealdb.com/api/json/v1/1/filter.php?i=$firstIngredient'));
      final data = jsonDecode(res.body);
      setState(() {
        _matchingRecipes = data['meals'] ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cook With What You Have 🍳"), backgroundColor: const Color(0xFFFFF8F5), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Add ingredient (e.g. Paneer)",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      setState(() {
                        _ingredients.add(_controller.text.trim());
                        _controller.clear();
                      });
                    }
                  },
                  icon: const Icon(Icons.add_circle, color: Color(0xFFC95675), size: 36),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: _ingredients.map((ing) => Chip(
                label: Text(ing),
                backgroundColor: const Color(0xFFF9DCE3),
                onDeleted: () => setState(() => _ingredients.remove(ing)),
              )).toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _searchRecipes,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC95675)),
              child: const Text("Find Recipes", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _matchingRecipes.length,
                itemBuilder: (context, index) {
                  final recipe = _matchingRecipes[index];
                  return ListTile(
                    leading: Image.network(recipe['strMealThumb'], width: 50, height: 50, fit: BoxFit.cover),
                    title: Text(recipe['strMeal']),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailScreen(mealId: recipe['idMeal']))),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("Explore Cuisines")));
}

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("Saved Recipes")));
}

class ProfileScreen extends StatelessWidget {
  final String userName;
  final Function(String) onNameChanged;
  const ProfileScreen({super.key, required this.userName, required this.onNameChanged});
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text("Profile: $userName")));
}

class RecipeDetailScreen extends StatelessWidget {
  final String mealId;
  const RecipeDetailScreen({super.key, required this.mealId});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("Recipe Details")), body: Center(child: Text("Meal ID: $mealId")));
}
EOF
