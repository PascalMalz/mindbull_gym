import 'package:flutter/material.dart';

import 'category_screen.dart';

void main() {
  runApp(Library());
}

class Library extends StatefulWidget {
  const Library({Key? key}) : super(key: key);

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MusicLibraryHomeScreen(),
    );
  }
}

class MusicLibraryHomeScreen extends StatelessWidget {
  final List<String> categories = [
    'All',
    'Favourites',
    'Recommendations',
    'Best Reviewed',
    'Self Esteem',
    'Loose Wheight',
    'Erotic',
    'ASMR',
    'Progressive Muscle Relaxation (PMR)',
    'Sports / Accuracy',
    'Public Speaking',
    'Confidence',
    'Be Feminine',
    'Be Masculine',
    'While Sleep',
    'Awake',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.grey.shade900,
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Music Library'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              _showFilterOptions(context);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(height: 10),
              ),
              SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 2,
                ),
                delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                    return _buildCategoryCard(context, categories[index]);
                  },
                  childCount: categories.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return FilterOptionsScreen();
      },
    );
  }

  Widget _buildCategoryCard(BuildContext context, String categoryName) {
    return GestureDetector(
      onTap: () {
        print("Tapped on category: $categoryName"); // Add this line
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryScreen(categoryName: categoryName),
          ),
        );
      },
      child: Container(
        height: 80,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.deepPurple,
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple,
                blurRadius: 3.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                categoryName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FilterOptionsScreen extends StatefulWidget {
  @override
  _FilterOptionsScreenState createState() => _FilterOptionsScreenState();
}

class _FilterOptionsScreenState extends State<FilterOptionsScreen> {
  bool _showPrograms = true;
  bool _showSingleSounds = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Filtering Options',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Programs'),
              Switch(
                value: _showPrograms,
                onChanged: (value) {
                  setState(() {
                    _showPrograms = value;
                  });
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Single Sounds'),
              Switch(
                value: _showSingleSounds,
                onChanged: (value) {
                  setState(() {
                    _showSingleSounds = value;
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Apply Filter'),
          ),
        ],
      ),
    );
  }
}


