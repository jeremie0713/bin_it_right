// import 'package:bin_it_right/screens/home_screen.dart';
// import 'package:bin_it_right/theme/app_theme.dart';
// import 'package:flutter/material.dart';


// void main() {
//   runApp(const BinItRightApp());
// }

// class BinItRightApp extends StatelessWidget {
//   const BinItRightApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: "Bin It Right!",
//       debugShowCheckedModeBanner: false,
//       theme: AppTheme.light(),
//       home: const HomeScreen(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BinItRightApp());
}

class BinItRightApp extends StatelessWidget {
  const BinItRightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bin It Right!',
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.fredokaTextTheme(),
      ),
      home: const HomeScreen(),
    );
  }
}
