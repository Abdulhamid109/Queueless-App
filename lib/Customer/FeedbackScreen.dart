import 'package:flutter/material.dart';
import 'package:queueless/Widgets/CustomerAppbar.dart';
import 'package:queueless/Widgets/CustomerDrawer.dart';

class Feedbackscreen extends StatefulWidget {
  const Feedbackscreen({super.key});

  @override
  State<Feedbackscreen> createState() => _FeedbackscreenState();
}

class _FeedbackscreenState extends State<Feedbackscreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  static const Color navy = Color(0xFF1A1A2E);
  static const Color cream = Color(0xFFF5F0EB);
  static const Color gold = Color(0xFFC9A96E);
  static const Color fieldBg = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE8E1D8);
  static const Color mutedText = Color(0xFF8A7E72);

  static const int _maxChars = 300;

  @override
  void initState() {
    super.initState();
    _descController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

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
  Widget build(BuildContext context) {
    final int charCount = _descController.text.length;
    final bool overLimit = charCount > _maxChars;

    return Scaffold(
      backgroundColor: navy,
      appBar: Customerappbar(),
      drawer: Customerdrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "FEEDBACK",
                    style: TextStyle(
                      color: Color(0xFF8A8FA8),
                      fontSize: 11,
                      letterSpacing: 1.8,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Share Your Feedback",
                    style: TextStyle(
                      color: cream,
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Tell us what issues you're facing or how we can improve the system.",
                    style: TextStyle(
                      color: Color(0xFF8A8FA8),
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              decoration: BoxDecoration(
                color: cream,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "YOUR FEEDBACK",
                      style: TextStyle(
                        color: mutedText,
                        fontSize: 11,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Issue Title
                    Text(
                      "Issue Title",
                      style: TextStyle(
                        color: navy,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 6),
                    TextFormField(
                      controller: _titleController,
                      decoration: _fieldDecoration(
                        "e.g. Queue not updating in real-time",
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? "Enter a title" : null,
                    ),
                    SizedBox(height: 16),

                    // Issue Description
                    Text(
                      "Issue Description",
                      style: TextStyle(
                        color: navy,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 6),
                    TextFormField(
                      controller: _descController,
                      maxLines: 6,
                      maxLength: _maxChars,
                      buildCounter: (context,
                              {required currentLength,
                              required isFocused,
                              maxLength}) =>
                          null, // hide default counter, we use our own
                      decoration: _fieldDecoration(
                        "Describe the issue or suggestion in detail...",
                      ).copyWith(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: overLimit ? Colors.redAccent : border,
                            width: 1.5,
                          ),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return "Enter a description";
                        if (v.length > _maxChars)
                          return "Description must be under $_maxChars characters";
                        return null;
                      },
                    ),
                    // Custom character counter
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          "$charCount / $_maxChars characters",
                          style: TextStyle(
                            color: overLimit ? Colors.redAccent : mutedText,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // TODO: submit feedback
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
                          "Submit Feedback",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Center(
                      child: Text(
                        "We review every submission and use it to improve the platform.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: mutedText, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}