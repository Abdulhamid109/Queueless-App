import 'package:flutter/material.dart';
import 'package:queueless/Widgets/CustomerAppbar.dart';
import 'package:queueless/Widgets/CustomerDrawer.dart';

class Aboutusscreen extends StatelessWidget {
  const Aboutusscreen({super.key});

  static const Color navy = Color(0xFF1A1A2E);
  static const Color cream = Color(0xFFF5F0EB);
  static const Color gold = Color(0xFFC9A96E);
  static const Color fieldBg = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE8E1D8);
  static const Color mutedText = Color(0xFF8A7E72);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      appBar: Customerappbar(),
      drawer: Customerdrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Hero (navy bg) ──────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ABOUT US",
                    style: TextStyle(
                      color: Color(0xFF8A8FA8),
                      fontSize: 11,
                      letterSpacing: 1.8,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "We're eliminating the wait,\none queue at a time.",
                    style: TextStyle(
                      color: cream,
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Queueless is a smart queue management platform built to give people their time back — and help businesses serve customers with precision, fairness, and zero chaos.",
                    style: TextStyle(
                      color: Color(0xFF8A8FA8),
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            // ── White card body ─────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: cream,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Mission
                  _sectionLabel("OUR MISSION"),
                  SizedBox(height: 8),
                  Text(
                    "Time is the only resource you can't get back.",
                    style: TextStyle(
                      color: navy,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "We started Queueless because we believe waiting in line is a solved problem. With the right technology, businesses can coordinate their customers intelligently — and customers can show up exactly when they're needed, not a minute before.",
                    style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 13, height: 1.7),
                  ),
                  SizedBox(height: 16),

                  // Quote
                  Container(
                    decoration: BoxDecoration(
                      border: Border(left: BorderSide(color: gold, width: 3)),
                    ),
                    padding: EdgeInsets.only(left: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '"No more guessing. No more crowded lobbies. Just seamless, location-aware service — for everyone."',
                          style: TextStyle(
                            color: navy,
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            height: 1.6,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "— The Queueless Team",
                          style: TextStyle(color: mutedText, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 28),

                  // Stats
                  _sectionLabel("BY THE NUMBERS"),
                  SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.6,
                    children: [
                      _statCard("0", "Minutes of unnecessary waiting"),
                      _statCard("Live", "Real-time queue updates via SSE"),
                      _statCard("50m", "Location precision radius"),
                      _statCard("Auto", "Slot rebalancing on no-shows"),
                    ],
                  ),
                  SizedBox(height: 28),

                  // Principles
                  _sectionLabel("CORE PRINCIPLES"),
                  SizedBox(height: 10),
                  _principleCard("⏱", "Punctuality", "Every customer gets a precise slot. No overbooking, no surprises."),
                  SizedBox(height: 10),
                  _principleCard("📍", "Location-aware", "We confirm your presence within 50 meters before your slot begins."),
                  SizedBox(height: 10),
                  _principleCard("⚖️", "Fairness", "Missed slots are rebalanced instantly so no one waits longer than they should."),
                  SizedBox(height: 10),
                  _principleCard("🔒", "Transparency", "Real-time position updates and wait estimates, always visible to the customer."),
                  SizedBox(height: 28),

                  // Team
                  _sectionLabel("THE TEAM"),
                  SizedBox(height: 10),
                  _teamCard("Ab", "Abdulhamid", "Founder", "Product & Engineering"),
                  SizedBox(height: 10),
                  _teamCard("QL", "Queueless Labs", "Team", "Research & Infrastructure"),
                  SizedBox(height: 28),

                  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        color: mutedText,
        fontSize: 11,
        letterSpacing: 1.5,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _statCard(String value, String label) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: fieldBg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: TextStyle(color: gold, fontSize: 22, fontWeight: FontWeight.w700)),
          SizedBox(height: 4),
          Text(label, style: TextStyle(color: mutedText, fontSize: 11, height: 1.4)),
        ],
      ),
    );
  }

  Widget _principleCard(String emoji, String title, String desc) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: fieldBg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: TextStyle(fontSize: 22)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: navy, fontSize: 14, fontWeight: FontWeight.w600)),
                SizedBox(height: 4),
                Text(desc, style: TextStyle(color: mutedText, fontSize: 12, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _teamCard(String initials, String name, String role, String dept) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: fieldBg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: navy,
            child: Text(initials, style: TextStyle(color: gold, fontWeight: FontWeight.w700, fontSize: 13)),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: TextStyle(color: navy, fontSize: 14, fontWeight: FontWeight.w600)),
              SizedBox(height: 2),
              Text(role, style: TextStyle(color: gold, fontSize: 12)),
              SizedBox(height: 2),
              Text(dept, style: TextStyle(color: mutedText, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}