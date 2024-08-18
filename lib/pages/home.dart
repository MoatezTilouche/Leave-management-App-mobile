import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intern_app/pages/LeaveRequest.dart';
import 'package:intern_app/pages/calendar.dart';
import 'package:intern_app/pages/conges_page.dart';
import 'package:intern_app/services/api_stats_service.dart';
import 'package:intern_app/pages/pie.dart';
import 'bottomBar.dart';
import 'appBarr.dart';
import 'package:http/http.dart' as http;
import 'sidebar.dart'; 
import 'package:shimmer/shimmer.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _notificationCount = 0;
  final StatsService _statsService = StatsService();
  int _acceptedLeaves = 0;
  int _refusedLeaves = 0;
  int _pendingLeaves = 0;
  double _averLeaveDays = 0.0; 
  int countTotalDaysConges = 0;
  String _id = '';
  String _name = '';
  int _soldeConges = 0;
  int _previousSoldeConges = 0; 
  int _previousSoldeMaladie = 0; 
  String _email = '';
  String _imageUrl = '';
  int _soldeMaladie = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true; 

  @override
  void initState() {
    super.initState();
    _loadUserProfile(); 
  }

  void _incrementNotificationCount() {
    setState(() {
      _notificationCount++;
    });
  }

  Future<void> _fetchStats() async {
    try {
      final acceptedLeaves = await _statsService.fetchAcceptedLeavesCurrentMonth();
      final refusedLeaves = await _statsService.fetchRefusedLeavesCurrentMonth();
      final pendingLeaves = await _statsService.fetchPendingLeavesCurrentMonth();
      final averLeaveDays = await _statsService.fetchAverageLeaveDays();
      
      setState(() {
        _acceptedLeaves = acceptedLeaves;
        _refusedLeaves = refusedLeaves;
        _pendingLeaves = pendingLeaves;
        _averLeaveDays = averLeaveDays;
        _isLoading = false; 
      });

      if (_id.isNotEmpty) {
        final countTotalDaysConges = await _statsService.countTotalDaysConges(_id);
        setState(() {
          this.countTotalDaysConges = countTotalDaysConges;
        });
      }
    } catch (e) {
      print('Error fetching stats: $e');
      setState(() {
        _isLoading = false; 
      });
    }
  }

  Future<void> _loadUserProfile() async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.243:3000/auth/profile'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = jsonDecode(response.body);
        setState(() {
          _name = userData['name'] ?? '';
           
          _soldeConges = userData['soldeConges'] ?? 0;
          _id = userData['_id'] ?? '';
          _email = userData['email'] ?? '';
          _imageUrl = userData['photo'] ?? '';
          _previousSoldeMaladie = _soldeMaladie;
          _soldeMaladie = userData['soldeMaladie'] ?? 0;
        });
       
        _fetchStats();
      } else {
        print('Failed to load user profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to connect to the server: $e');
    }
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  Widget _buildShimmerLoading() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10.0,
      mainAxisSpacing: 10.0,
      childAspectRatio: 1.4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(4, (index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 60,
                    height: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 25,
                        height: 25,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 40,
                        height: 20,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildShimmerLoadingForPieChart() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: 210.0,
        height: 210.0,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildLeaveBalanceCard() {
    bool hasDecreased = _soldeConges < _previousSoldeConges;
    bool hasIncreased = _soldeConges > _previousSoldeConges;
    int decreaseAmount = _previousSoldeConges - _soldeConges;
    int increaseAmount = _soldeConges - _previousSoldeConges;

    return Card(
      color: const Color(0xFF1640D6),
      child: InkWell(
        onTap: () {
          
        },
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "Votre solde de congé",
                style: const TextStyle(
                  fontSize: 11.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 25.0,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _soldeConges.toString(),
                    style: const TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
              if (hasDecreased) ...[
                const SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_downward,
                      size: 20.0,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '-$decreaseAmount',
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ],
              if (hasIncreased) ...[
                const SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_upward,
                      size: 20.0,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '+$increaseAmount',
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaveBalanceMalCard() {
    bool hasDecreased = _soldeMaladie < _previousSoldeMaladie;
    bool hasIncreased = _soldeMaladie > _previousSoldeMaladie;
    int decreaseAmount = _previousSoldeMaladie - _soldeMaladie;
    int increaseAmount = _soldeMaladie - _previousSoldeMaladie;

    return Card(
      color: const Color(0xFF818FB4),
      child: InkWell(
        onTap: () {
          // Add your onTap action here
        },
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "Votre solde de Maladie",
                style: const TextStyle(
                  fontSize: 11.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ImageIcon(
                    AssetImage("assets/croix.png"),
                    size: 25.0,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _soldeMaladie.toString(),
                    style: const TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
              if (hasDecreased) ...[
                const SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_downward,
                      size: 20.0,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '-$decreaseAmount',
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ],
              if (hasIncreased) ...[
                const SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_upward,
                      size: 20.0,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '+$increaseAmount',
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFEBF4F6),
      appBar: CustomAppBar(
       employeId: _id,
      ),
      drawer: AppDrawer(
        name: _name,
        email: _email,
        imageUrl: _imageUrl,
      ),
      body: _isLoading
          ? Column(
              children: [
                _buildShimmerLoading(),
                SizedBox(height: 30.0),
                _buildShimmerLoadingForPieChart(),
              ],
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Welcome, $_name",
                    style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: 1.4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(4, (index) {
                      Color cardColor;
                      Widget cardIcon;
                      String cardText;
                      String cardValue;
                      VoidCallback? onTap;
                      Widget? cardButton;

                      switch (index) {
                        case 0:
                          return _buildLeaveBalanceCard();
                        case 1:
                          return _buildLeaveBalanceMalCard();
                        case 2:
                          cardColor = const Color(0xFF5A72A0);
                          cardIcon = ImageIcon(AssetImage("assets/time-and-calendar.png"),size: 30,color:Colors.white,);
                          cardText = "Voir Demande de congés acceptés";
                          cardValue = _acceptedLeaves.toString();
                          onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => LeaveCalendar()),
                            );
                          };
                          break;
                        // case 3:
                        //   cardColor = const Color(0xFF2B3499);
                        //   cardIcon = Icon(Icons.date_range, size: 25.0, color: Colors.white);
                        //   cardText = "Nombre de jours congés pris cette année";
                        //   cardValue = countTotalDaysConges.toString();
                        //   break;
                        // case 4:
                        //   cardColor = const Color(0xFF3ABEF9);
                        //   cardIcon = Icon(Icons.access_time, size: 25.0, color: Colors.white);
                        //   cardText = "Jours de congé moyens";
                        //   cardValue = _averLeaveDays.toStringAsFixed(1);
                        //   break;
                        case 3:
                          cardColor = const Color(0xFF37B7C3);
                          cardIcon = Icon(Icons.history, size: 25.0, color: Colors.white);
                          cardText = "Historique des congés";
                          cardValue = "Voir";
                          onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => CongesListPage(employeId: _id)),
                            );
                          };
                          break;
                        default:
                          cardColor = const Color(0xFF707070);
                          cardIcon = Icon(Icons.help_outline, size: 25.0, color: Colors.white);
                          cardText = "Unknown";
                          cardValue = "-";
                      }

                      return Card(
                        color: cardColor,
                        child: InkWell(
                          onTap: onTap,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  cardText,
                                  style: const TextStyle(
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 10.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    cardIcon,
                                    const SizedBox(width: 10),
                                    Text(
                                      cardValue,
                                      style: const TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10.0),
                                if (cardButton != null) cardButton!,
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 30.0),
                  LeaveTypePieChart(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Leaverequest()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color(0xFF4CB9E7),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: DemoBottomAppBar(
        scaffoldKey: _scaffoldKey,
        selectedIndex: 0,
      ),
    );
  }
}
