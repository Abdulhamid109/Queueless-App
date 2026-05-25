import 'package:flutter/material.dart';
import 'package:queueless/Widgets/CustomerAppbar.dart';
import 'package:queueless/Widgets/CustomerDrawer.dart';

class Contactscreen extends StatefulWidget {
  const Contactscreen({super.key});

  @override
  State<Contactscreen> createState() => _ContactscreenState();
}

class _ContactscreenState extends State<Contactscreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  static const Color navy = Color(0xFF1A1A2E);
  static const Color cream = Color(0xFFF5F0EB);
  static const Color gold = Color(0xFFC9A96E);
  static const Color fieldBg = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE8E1D8);
  static const Color mutedText = Color(0xFF8A7E72);

  final List<Map<String, String>> _faqs = [
    {
      'q': 'How do I join a queue?',
      'a': 'Search for a business, select your services, and tap Join Queue. You\'ll receive a notification 10 minutes before your turn.',
    },
    {
      'q': 'What happens if I miss my slot?',
      'a': 'If you\'re not within 50 meters of the business when your slot starts, it will be marked as missed and the next person will be served. You can rejoin the queue.',
    },
    {
      'q': 'Can I join queues at multiple businesses?',
      'a': 'Yes. Each business queue is tracked independently, so you can be in multiple queues at the same time.',
    },
    {
      'q': 'Is Queueless free to use?',
      'a': 'Queueless is free for customers. Business plans are available for service providers who want advanced analytics and management tools.',
    },
  ];

  final List<int> _expandedFaqs = [];

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: mutedText, fontSize: 13),
      filled: true,
      fillColor: fieldBg,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: border, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: gold, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      appBar: Customerappbar(),
      drawer: Customerdrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Hero ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "CONTACT US",
                    style: TextStyle(
                      color: Color(0xFF8A8FA8),
                      fontSize: 11,
                      letterSpacing: 1.8,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Let's talk.",
                    style: TextStyle(
                      color: cream,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Have a question, a suggestion, or just want to say hello? We're a small team and we read every message.",
                    style: TextStyle(
                      color: Color(0xFF8A8FA8),
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            // ── Cream body ─────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: cream,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Reach us
                    _sectionLabel("REACH US"),
                    SizedBox(height: 10),
                    _contactCard("✉", "Email us", "hello@queueless.in", "We reply within 24 hours"),
                    SizedBox(height: 10),
                    _contactCard("📍", "Based in", "Navi Mumbai, India", "Maharashtra, 400701"),
                    SizedBox(height: 10),
                    _contactCard("🕐", "Support hours", "Mon – Sat, 9am – 6pm", "IST (UTC +5:30)"),
                    SizedBox(height: 10),
                    _contactCard("💬", "Feedback", "Share your experience", "Help us improve the platform"),
                    SizedBox(height: 28),

                    // Send a message
                    _sectionLabel("SEND A MESSAGE"),
                    SizedBox(height: 8),
                    Text(
                      "We'll get back to you within a day.",
                      style: TextStyle(
                        color: navy,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: _fieldDecoration("Name"),
                      validator: (v) => v == null || v.isEmpty ? "Enter your name" : null,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _fieldDecoration("Email"),
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Enter your email";
                        if (!v.contains('@')) return "Enter a valid email";
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _subjectController,
                      decoration: _fieldDecoration("Subject"),
                      validator: (v) => v == null || v.isEmpty ? "Enter a subject" : null,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _messageController,
                      maxLines: 5,
                      decoration: _fieldDecoration("Message"),
                      validator: (v) => v == null || v.isEmpty ? "Enter your message" : null,
                    ),
                    SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // TODO: submit
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: navy,
                          foregroundColor: cream,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "Send Message",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Center(
                      child: Text(
                        "We don't share your data with anyone.",
                        style: TextStyle(color: mutedText, fontSize: 11),
                      ),
                    ),
                    SizedBox(height: 28),

                    // FAQ
                    _sectionLabel("FAQ"),
                    SizedBox(height: 8),
                    Text(
                      "Common questions.",
                      style: TextStyle(
                        color: navy,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12),
                    ...List.generate(_faqs.length, (i) => _faqCard(i)),
                    SizedBox(height: 28),

                    
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) => Text(
        label,
        style: TextStyle(
          color: mutedText,
          fontSize: 11,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w500,
        ),
      );

  Widget _contactCard(String emoji, String title, String line1, String line2) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: fieldBg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: navy,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text(emoji, style: TextStyle(fontSize: 18))),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: navy, fontSize: 14, fontWeight: FontWeight.w600)),
                SizedBox(height: 2),
                Text(line1, style: TextStyle(color: gold, fontSize: 12)),
                SizedBox(height: 2),
                Text(line2, style: TextStyle(color: mutedText, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _faqCard(int index) {
    final isExpanded = _expandedFaqs.contains(index);
    return GestureDetector(
      onTap: () => setState(() {
        isExpanded ? _expandedFaqs.remove(index) : _expandedFaqs.add(index);
      }),
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: fieldBg,
          border: Border.all(color: isExpanded ? gold : border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _faqs[index]['q']!,
                    style: TextStyle(
                      color: navy,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: mutedText,
                  size: 20,
                ),
              ],
            ),
            if (isExpanded) ...[
              SizedBox(height: 8),
              Text(
                _faqs[index]['a']!,
                style: TextStyle(color: mutedText, fontSize: 12, height: 1.5),
              ),
            ],
          ],
        ),
      ),
    );
  }
}