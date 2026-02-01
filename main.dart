import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vibration/vibration.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final seed = Colors.cyanAccent.shade200;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Home — Premium',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme:
            ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
        scaffoldBackgroundColor: const Color(0xFF071021),
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final rooms = [
      {"name": "ห้องนั่งเล่น", "ip": ""},
      {"name": "ห้องครัว", "ip": ""},
      {"name": "ห้องนอน (พี่ชาย)", "ip": ""},
      {"name": "ห้องนอน (น้องสาว)", "ip": ""},
      {"name": "ห้องปู่ย่า", "ip": ""},
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const _TitleColumn(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.settings,
                        size: 26, color: Colors.white70),
                  )
                ],
              ),
              const SizedBox(height: 18),
              const _SummaryCard(),
              const SizedBox(height: 18),
              Expanded(
                child: GridView.builder(
                  itemCount: rooms.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 120,
                  ),
                  itemBuilder: (context, i) {
                    final r = rooms[i];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration:
                                const Duration(milliseconds: 450),
                            pageBuilder: (_, __, ___) => RoomControlPage(
                              roomName: r['name']!,
                              esp32Ip: r['ip']!,
                            ),
                            transitionsBuilder: (_, anim, __, child) {
                              return FadeTransition(
                                  opacity: anim, child: child);
                            },
                          ),
                        );
                      },
                      child: _RoomCard(name: r['name']!),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TitleColumn extends StatelessWidget {
  const _TitleColumn();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Smart Home',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
        SizedBox(height: 4),
        Text('ไว้ใจเรา กีต้าร์ไม่ได้กล่าวเเต่ใครกล่าวไม่รู้',
            style: TextStyle(fontSize: 13, color: Colors.white70)),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard();
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 8)
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                      colors: [Colors.cyan.shade400, Colors.blue.shade700]),
                ),
                child: const Icon(Icons.shield, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('ระบบรักษาความปลอดภัยบ้าน',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    SizedBox(height: 6),
                    Text(
                        'ตรวจสอบอุณหภูมิ, ความชื้น และการเคลื่อนไหว ,คำนวณการใช้ไฟฟ้า',
                        style: TextStyle(fontSize: 12, color: Colors.white70)),
                  ],
                ),
              ),
              IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert, color: Colors.white70))
            ],
          ),
        ),
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final String name;
  const _RoomCard({required this.name});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.04)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.all(8),
                    child:
                        const Icon(Icons.meeting_room, color: Colors.white70),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: Colors.white54)
                ],
              ),
              const Spacer(),
              Text(name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= ROOM CONTROL =================
class RoomControlPage extends StatefulWidget {
  final String roomName;
  final String esp32Ip;
  const RoomControlPage(
      {super.key, required this.roomName, required this.esp32Ip});

  @override
  State<RoomControlPage> createState() => _RoomControlPageState();
}

class _RoomControlPageState extends State<RoomControlPage>
    with SingleTickerProviderStateMixin {
  String temperature = "--";
  String humidity = "--";
  bool motionDetected = false;
  String motionTime = "-";
  bool powerCut = false;
  bool autoMode = false;
  double electricityUsage = 0.0; // kWh
  String status = "";
  Timer? timer;
  Timer? autoTimer;
  Random random = Random();

  late AnimationController _animController;
  late Animation<double> _bannerOpacity;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _bannerOpacity =
        CurvedAnimation(parent: _animController, curve: Curves.easeInOut);

    timer =
        Timer.periodic(const Duration(seconds: 5), (_) => _updateFakeData());
  }

  @override
  void dispose() {
    timer?.cancel();
    autoTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _updateFakeData() {
    setState(() {
      temperature = "30.1";
      humidity = (40 + random.nextDouble() * 20).toStringAsFixed(1);
      motionDetected = random.nextInt(10) > 7;
      if (motionDetected) {
        motionTime = _nowTime();
        _animController.forward();
        electricityUsage += 0.01; // สมมุติไฟใช้งานเพิ่ม
        if (autoMode && powerCut) _cutPower(false); // เปิดไฟถ้าเจอการเคลื่อนไหว
      } else {
        _animController.reverse();
      }
    });
  }

  String _nowTime() {
    final n = DateTime.now();
    return "${n.hour.toString().padLeft(2, '0')}:${n.minute.toString().padLeft(2, '0')}:${n.second.toString().padLeft(2, '0')}";
  }

  Future<void> sendCommand(String path) async {
    try {
      final res = await http
          .get(Uri.parse("http://${widget.esp32Ip}$path"))
          .timeout(const Duration(seconds: 4));
      setState(() => status = res.body);
    } catch (e) {
      setState(() => status = "Error: $e");
    }
  }

  void _cutPower([bool cut = true]) {
    setState(() => powerCut = cut);
  }

  void _toggleAutoMode() {
    setState(() {
      autoMode = !autoMode;
      if (autoMode) {
        autoTimer = Timer.periodic(const Duration(minutes: 1), (_) {
          if (!motionDetected) {
            // ถ้าไม่มี motion 30 นาทีให้ตัดไฟ
            _cutPower(true);
            electricityUsage += 0.05; // สมมุติไฟที่ยังนับ
          } else {
            _cutPower(false); // เปิดไฟทันที
          }
        });
      } else {
        autoTimer?.cancel();
      }
    });
  }

  Widget _glassCard({required Widget child, EdgeInsetsGeometry? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding ?? const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.04)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _controlButton(String label, IconData icon, Color bg, String path) {
    return ElevatedButton.icon(
      onPressed: powerCut ? null : () => sendCommand(path),
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 6,
      ),
      icon: Icon(icon, size: 20),
      label: Text(label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.roomName,
            style: const TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            SizeTransition(
              sizeFactor: _bannerOpacity,
              axisAlignment: -1,
              child: _glassCard(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                child: Row(
                  children: [
                    const Icon(Icons.motion_photos_on, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            motionDetected
                                ? 'ตรวจพบการเคลื่อนไหว'
                                : 'ไม่พบการเคลื่อนไหว',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: motionDetected
                                    ? Colors.orangeAccent
                                    : Colors.greenAccent),
                          ),
                          const SizedBox(height: 4),
                          Text('เวลาล่าสุด: $motionTime',
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.white70)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _glassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('อุณหภูมิ',
                            style: TextStyle(color: Colors.white70)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.thermostat, size: 28),
                            const SizedBox(width: 10),
                            Text('$temperature °C',
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _glassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ความชื้น',
                            style: TextStyle(color: Colors.white70)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.water_drop, size: 28),
                            const SizedBox(width: 10),
                            Text('$humidity %',
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _glassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Controls',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: _controlButton('เปิดไฟ', Icons.lightbulb,
                              Colors.green, '/led/on')),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _controlButton('ปิดไฟ',
                              Icons.lightbulb_outline, Colors.red, '/led/off')),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 🔹 เปิด/ปิดพัดลม
                  Row(
                    children: [
                      Expanded(
                        child: _controlButton(
                            'เปิดพัดลม', Icons.air, Colors.blue, '/fan/on'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _controlButton('ปิดพัดลม', Icons.stop_circle,
                            Colors.grey, '/fan/off'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _controlButton(
                          'ตัดไฟทั้งห้อง',
                          Icons.power_settings_new,
                          Colors.deepOrange,
                          '/led/off',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _controlButton(
                          'เปิดไฟทั้งห้องคืน',
                          Icons.flash_on,
                          Colors.red.shade900,
                          '/led/on',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _toggleAutoMode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                autoMode ? Colors.green : Colors.grey.shade700,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 6,
                          ),
                          icon: const Icon(Icons.autorenew, size: 20),
                          label: Text(
                              autoMode
                                  ? 'โหมดอัตโนมัติ ON'
                                  : 'โหมดอัตโนมัติ OFF',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text('ค่าไฟสะสม: ${electricityUsage.toStringAsFixed(2)} kWh',
                      style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _glassCard(
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white70),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text('Status: $status',
                          style: const TextStyle(color: Colors.white70))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

