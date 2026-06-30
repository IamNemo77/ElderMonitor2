import 'dart:async';
import 'package:flutter/material.dart';
import 'alert_model.dart';

void main() => runApp(const SmartElderlyMonitorApp());

class SmartElderlyMonitorApp extends StatelessWidget {
  const SmartElderlyMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Elderly Monitor',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.deepOrange,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const MainDashboardScreen(),
    );
  }
}

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  // --- Required Feature States ---
  bool isConnected = true; // Connection Status
  String currentMode = "Normal"; // Normal, Sleep, Warning, Emergency
  int batteryLevel = 92; // Battery Monitoring
  int warningCountdown = 10; // 10-second Warning Stage Countdown
  Timer? _countdownTimer;

  // List to hold historical alerts
  final List<AlertItem> _historyLogs = [
    AlertItem(
      id: "1",
      timestamp: "10:15 AM",
      type: "Inactivity",
      status: "Resolved",
    ),
    AlertItem(
      id: "2",
      timestamp: "08:30 AM",
      type: "Fall",
      status: "Confirmed",
    ),
  ];

  // --- Core UI Logic & State Controls ---
  void _triggerWarningStage(String alertType) {
    if (_countdownTimer != null) _countdownTimer!.cancel();
    setState(() {
      currentMode = "Warning";
      warningCountdown = 10;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (warningCountdown > 1) {
        setState(() => warningCountdown--);
      } else {
        timer.cancel();
        setState(() => currentMode = "Emergency");
      }
    });
  }

  void _cancelOrResetAlert() {
    if (_countdownTimer != null) _countdownTimer!.cancel();
    setState(() {
      currentMode = "Normal";
      warningCountdown = 10;
    });
  }

  void _toggleSleepMode() {
    setState(() {
      currentMode = (currentMode == "Sleep") ? "Normal" : "Sleep";
    });
  }

  @override
  Widget build(BuildContext context) {
    // Dynamically show the Emergency Screen if an alert is active
    bool showAlertScreen =
        (currentMode == "Emergency" || currentMode == "Warning");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Elderly Emergency Monitor"),
        backgroundColor: currentMode == "Emergency"
            ? Colors.red[900]
            : Colors.grey[900],
        actions: [
          // Bluetooth Connection Status Icon
          Icon(
            isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
            color: isConnected ? Colors.greenAccent : Colors.redAccent,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: showAlertScreen
          ? _buildEmergencyStatusScreen()
          : _buildStandardDashboard(),
    );
  }

  // --- UI Screen 1: Standard Dashboard View ---
  Widget _buildStandardDashboard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Diagnostic status bar row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isConnected ? "🟢 Connected to Band" : "🔴 Band Disconnected",
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                "🔋 Battery: $batteryLevel%",
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Current System Mode Card Display
          Card(
            color: Colors.grey[900],
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Text(
                    "CURRENT MODE STATUS",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentMode.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _toggleSleepMode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey[800],
                    ),
                    child: Text(
                      currentMode == "Sleep"
                          ? "Deactivate Sleep Mode"
                          : "Activate Sleep Mode",
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Simulation Triggers (Use these to test before your hardware is ready!)
          const Text(
            "Test Simulation Triggers:",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _triggerWarningStage("Fall"),
                  child: const Text("Trigger Fall"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() => currentMode = "Emergency"),
                  child: const Text("Instant Panic"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Alert History Header
          const Text(
            "Alert History Logs",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Scrollable Alert History List
          Expanded(
            child: ListView.builder(
              itemCount: _historyLogs.length,
              itemBuilder: (context, index) {
                final log = _historyLogs[index];
                return Card(
                  color: Colors.grey[850],
                  child: ListTile(
                    leading: const Icon(Icons.warning, color: Colors.amber),
                    title: Text("${log.type} Event - ${log.status}"),
                    subtitle: Text(log.timestamp),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- UI Screen 2: Emergency Status Screen ---
  Widget _buildEmergencyStatusScreen() {
    bool isWarning = (currentMode == "Warning");

    return Container(
      color: isWarning
          ? Colors.orange[900]!.withValues(alpha: 0.3)
          : Colors.red[950],
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isWarning ? Icons.hourglass_empty : Icons.gpp_bad,
            size: 80,
            color: isWarning ? Colors.amber : Colors.red,
          ),
          const SizedBox(height: 20),
          Text(
            isWarning ? "WARNING STATUS ACTIVE" : "EMERGENCY ALERT CONFIRMED",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            isWarning
                ? "A potential emergency was detected. Sending caregiver notifications in: $warningCountdown seconds."
                : "Critical assistance alert dispatched. Caregiver communication lines are active.",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 40),

          // Optional Alert Cancel/Reset Feature Button
          ElevatedButton(
            onPressed: _cancelOrResetAlert,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800],
              minimumSize: const Size.fromHeight(50),
            ),
            child: Text(
              isWarning ? "Cancel False Alarm" : "Reset System Status",
            ),
          ),
        ],
      ),
    );
  }
}
