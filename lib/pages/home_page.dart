import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:appbank/components/transactions.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:appbank/pages/payments_screens.dart';
import 'package:appbank/components/colors.dart';

class PaymentShortcut extends StatelessWidget {
  final String image;
  final String label;
  final double size;
  final Widget destPage;

  PaymentShortcut({
    Key? key,
    required this.image,
    required this.size,
    required this.label,
    required this.destPage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double baseWidth = 375;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return GestureDetector(
      onTap: () => {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destPage),
        )
      },
      child: Column(
        children: [
          Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: AppColors.darkGrey,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Center(
                child: Image(
                  image: AssetImage(image),
                  width: size / 2.5,
                  height: size / 2.5,
                ),
              )),
          SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.leagueSpartan(
              fontSize: 18 * ffem,
              fontWeight: FontWeight.w500,
              height: 0.92 * ffem / fem,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  User? user;
  String userId = '';
  static final List<Widget> _widgetOptions = <Widget>[
    HomeScreen(userId: ''),
    PaymentsScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedFontSize: 18,
        iconSize: 28,
        unselectedFontSize: 18,
        selectedLabelStyle:
            GoogleFonts.leagueSpartan(fontWeight: FontWeight.bold),
        unselectedLabelStyle:
            GoogleFonts.leagueSpartan(fontWeight: FontWeight.w500),
        unselectedItemColor: AppColors.darkGrey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Payments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.darkRed,
        onTap: _onItemTapped,
      ),
    );
  }
}

// class HomeScreen extends StatelessWidget {
//   Future<void> getUserData(String userId) async {
//     final userData =
//         await FirebaseFirestore.instance.collection('users').doc(userId).get();

//     if (userData.exists) {
//       final firstName = userData.data()!['First Name'];
//       final lastName = userData.data()!['Last Name'];
//       final numAcc = userData.data()!['Bank account number'];

//       print('Name: $firstName');
//       print('Age: $lastName');
//       print('Email: $numAcc');
//     } else {
//       print('User with ID $userId does not exist.');
//     }
//   }
class HomeScreen extends StatefulWidget {
  final String userId;

  const HomeScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String firstName = '';
  String lastName = '';
  String numAcc = '';
  String expires = '';
  @override
  void initState() {
    super.initState();
    getUserData(widget.userId);
  }

  Future<void> getUserData(String userId) async {
    User? user = FirebaseAuth.instance.currentUser;
    String userId = user!.uid;

    final userData =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userData.exists) {
      final userDoc = userData.data();
      setState(() {
        firstName = userDoc?['First Name'];
        lastName = userDoc?['Last Name'];
        numAcc = userDoc?['Bank account number'];
        expires = userDoc?['expires'];
      });
    } else {
      print('User with ID $userId does not exist.');
    }
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 375;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
        begin: Alignment(0, 0.546),
        end: Alignment(0, 1),
        colors: <Color>[AppColors.lightRed, AppColors.darkRed],
        stops: <double>[0, 1],
      )),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              './lib/images/home_bg.png',
              fit: BoxFit.fitWidth,
            ),
          ),
          Positioned(
            left: 77 * fem,
            top: 13 * fem,
            child: Image.asset(
              './lib/images/home_logo.png',
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 80,
              ),

              //Credit Ca rd
              Padding(
                  padding: EdgeInsets.fromLTRB(36, 0, 36, 0),
                  child: CreditCardWidget(
                    cardHolder: firstName + " " + lastName,
                    cardNumber: numAcc,
                    expiryDate: expires,
                  )),

              //Payment Methods
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 32 * fem, vertical: 14 * fem),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PaymentShortcut(
                      size: 66,
                      image: './lib/images/blik.png',
                      label: 'BLIK',
                      destPage: BLIKPayment(),
                    ),
                    PaymentShortcut(
                      size: 66,
                      image: './lib/images/przelew.png',
                      label: 'Transfer',
                      destPage: TransferPayment(),
                    ),
                    PaymentShortcut(
                      size: 66,
                      image: './lib/images/contactless.png',
                      label: 'Contactless',
                      destPage: ContactlessPayment(),
                    ),
                  ],
                ),
              ),
              //TO DO !!!!
              RecentTransactionsWidget(
                tranzakcje: [
                  Tranzakcja(
                    firstName: 'John',
                    lastName: 'Smith',
                    description: 'Grocery shopping',
                    amount: 30.00,
                  ),
                  Tranzakcja(
                    firstName: 'Amanda',
                    lastName: 'Black',
                    description: 'Gas refill',
                    amount: -15.40,
                  ),
                  Tranzakcja(
                    firstName: 'Shop',
                    lastName: '',
                    description: 'Groccery',
                    amount: -2.90,
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}

//IN PROGRESS
class PaymentsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0, 0.546),
          end: Alignment(0, 1),
          colors: <Color>[AppColors.lightRed, AppColors.darkRed],
          stops: <double>[0, 1],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.centerLeft,
            child: Text(
              'Payments',
              style: GoogleFonts.leagueSpartan(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ),
          Container(
            color: AppColors.grey.withAlpha(50),
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PaymentShortcut(
                    size: 70,
                    image: './lib/images/blik.png',
                    label: 'BLIK',
                    destPage: BLIKPayment(),
                  ),
                  PaymentShortcut(
                    size: 70,
                    image: './lib/images/przelew.png',
                    label: 'Transfer',
                    destPage: TransferPayment(),
                  ),
                  PaymentShortcut(
                    size: 70,
                    image: './lib/images/contactless.png',
                    label: 'Contactless',
                    destPage: ContactlessPayment(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//History page
class HistoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> tranzakcje = [
    {
      'date': DateTime(2023, 4, 1),
      'type': 'blik',
      'description': 'Grocery shopping',
      'name': 'John Smith',
      'account': '123456789',
      'amount': 30.0,
    },
    {
      'date': DateTime(2023, 4, 1),
      'type': 'przelew',
      'description': 'Gas refill',
      'name': 'Amanda Black',
      'account': '987654321',
      'amount': -15.40,
    },
    {
      'date': DateTime(2023, 4, 2),
      'type': 'blik',
      'description': 'Groccery',
      'name': 'Shop',
      'account': '456789123',
      'amount': -2.90,
    },
    {
      'date': DateTime(2023, 4, 2),
      'type': 'przelew',
      'description': 'Salary',
      'name': 'Walter White',
      'account': '321654987',
      'amount': 1280.00,
    },
    {
      'date': DateTime(2023, 4, 3),
      'type': 'blik',
      'description': 'TV bought',
      'name': 'TV shop',
      'account': '789123456',
      'amount': 750.0,
    },
    {
      'date': DateTime(2023, 4, 4),
      'type': 'przelew',
      'description': 'Food tip',
      'name': 'Restaurant',
      'account': '654987321',
      'amount': 12.50,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0, 0.546),
          end: Alignment(0, 1),
          colors: <Color>[AppColors.lightRed, AppColors.darkRed],
          stops: <double>[0, 1],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 22),
            alignment: Alignment.centerLeft,
            child: Text(
              'History',
              style: GoogleFonts.leagueSpartan(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tranzakcje.length,
              itemBuilder: (context, index) {
                final tranzakcja = tranzakcje[index];
                final currentDate = tranzakcja['date'] as DateTime;
                final formatter = DateFormat('yyyy-MM-dd');
                final formattedDate = formatter.format(currentDate);
                final isNegative = tranzakcja['amount'] < 0;
                final amountText =
                    '${isNegative ? '-' : ''}${tranzakcja['amount'].abs()}\$';
                bool showDivider = true;

                if (index > 0) {
                  final previousDate =
                      tranzakcje[index - 1]['date'] as DateTime;
                  showDivider = currentDate != previousDate;
                }

                return Column(
                  children: [
                    if (showDivider)
                      Container(
                        color: AppColors.grey,
                        padding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          formattedDate,
                          style: GoogleFonts.leagueSpartan(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: AppColors.darkGrey,
                          ),
                        ),
                      ),
                    Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: const BoxDecoration(
                        border: Border(
                            top: BorderSide(
                              color: AppColors.grey,
                              width: 1,
                            ),
                            bottom: BorderSide(
                              color: AppColors.grey,
                              width: 1,
                            )),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            './lib/images/${tranzakcja['type']}.png',
                            width: 25,
                            height: 25,
                          ),
                          SizedBox(width: 16.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tranzakcja['name'],
                                style: GoogleFonts.leagueSpartan(
                                  fontSize: 24,
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                tranzakcja['description'],
                                style: GoogleFonts.leagueSpartan(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.white),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                tranzakcja['account'],
                                style: GoogleFonts.leagueSpartan(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.grey),
                              ),
                            ],
                          ),
                          Spacer(),
                          Text(
                            amountText,
                            style: GoogleFonts.leagueSpartan(
                              color: isNegative
                                  ? AppColors.white
                                  : Color(0xff1fe9ad),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Profile Screen'),
    );
  }
}

//Credit Card
class CreditCardWidget extends StatelessWidget {
  final String cardHolder;
  final String cardNumber;
  final String expiryDate;

  const CreditCardWidget({
    Key? key,
    required this.cardHolder,
    required this.cardNumber,
    required this.expiryDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(1.038, -1),
          end: Alignment(-0.805, 0.943),
          colors: <Color>[Color(0x99020202), Color(0xce000000)],
          stops: <double>[0, 0.87],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.credit_card, color: Colors.white),
              Text(
                'VISA',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            cardNumber,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Card Holder',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 4),
                  Text(
                    cardHolder.toUpperCase(),
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Expires',
                    style: TextStyle(color: AppColors.white),
                  ),
                  SizedBox(height: 4),
                  Text(
                    expiryDate,
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
