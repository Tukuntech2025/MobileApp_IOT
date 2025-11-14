import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tukuntech/core/base_screen.dart';
import 'package:tukuntech/features/support/presentation/pages/create_ticket_page.dart';
import 'package:tukuntech/features/support/presentation/pages/my_tickets_page.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      currentIndex: -1, // No está en el bottom bar
      title: "Support",
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              "How can we help you?",
              style: GoogleFonts.josefinSans(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFF0E8D5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Find answers or contact our support team",
              style: GoogleFonts.darkerGrotesque(
                fontSize: 16,
                color: const Color(0xFFB0B0B0),
              ),
            ),
            const SizedBox(height: 24),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.add_circle_outline,
                    label: "Create Ticket",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateTicketPage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.inbox_outlined,
                    label: "My Tickets",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyTicketsPage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // FAQ Section
            Text(
              "Frequently Asked Questions",
              style: GoogleFonts.josefinSans(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFF0E8D5),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 16),
              height: 2,
              width: 100,
              color: const Color(0xFFD1AA10),
            ),

            // FAQ Items
            _FAQItem(
              question: "How do I monitor vital signs?",
              answer:
                  "Go to the Vital Signs section from the home screen. You can view real-time data and historical records.",
            ),
            _FAQItem(
              question: "How can I update my profile?",
              answer:
                  "Navigate to Profile, tap the Update button, and modify your information. Don't forget to save your changes.",
            ),
            _FAQItem(
              question: "What if I forget my password?",
              answer:
                  "On the login screen, tap 'Forgot Password' and follow the instructions sent to your email.",
            ),
            _FAQItem(
              question: "How do I contact technical support?",
              answer:
                  "You can create a support ticket using the 'Create Ticket' button above. Our team will respond within 24 hours.",
            ),
            _FAQItem(
              question: "Can I access my medical history?",
              answer:
                  "Yes, go to the History section to view all your medical records, treatments, and prescriptions.",
            ),

            const SizedBox(height: 24),

            // Contact Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF3A3A3A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Still need help?",
                    style: GoogleFonts.josefinSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFF0E8D5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Email: support@tukuntech.com\nPhone: +51 999 888 777",
                    style: GoogleFonts.darkerGrotesque(
                      fontSize: 16,
                      color: const Color(0xFFB0B0B0),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF3A3A3A)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFD1AA10), size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.josefinSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFF0E8D5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FAQItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FAQItem({
    required this.question,
    required this.answer,
  });

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isExpanded ? const Color(0xFFD1AA10) : const Color(0xFF3A3A3A),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            widget.question,
            style: GoogleFonts.josefinSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFF0E8D5),
            ),
          ),
          iconColor: const Color(0xFFD1AA10),
          collapsedIconColor: const Color(0xFFB0B0B0),
          onExpansionChanged: (expanded) {
            setState(() => _isExpanded = expanded);
          },
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                widget.answer,
                style: GoogleFonts.darkerGrotesque(
                  fontSize: 15,
                  color: const Color(0xFFB0B0B0),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}