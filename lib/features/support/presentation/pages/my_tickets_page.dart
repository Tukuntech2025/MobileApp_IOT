import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tukuntech/services/support_service.dart';
import 'package:intl/intl.dart';

class MyTicketsPage extends StatefulWidget {
  const MyTicketsPage({super.key});

  @override
  State<MyTicketsPage> createState() => _MyTicketsPageState();
}

class _MyTicketsPageState extends State<MyTicketsPage> {
  final SupportService _supportService = SupportService();
  List<Map<String, dynamic>> _tickets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    setState(() => _isLoading = true);
    try {
      final tickets = await _supportService.getMyTickets();
      if (mounted) {
        setState(() {
          _tickets = tickets;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('🔴 Error loading tickets: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading tickets: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1B1B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B1B1B),
        elevation: 0,
        title: Text(
          "My Tickets",
          style: GoogleFonts.darkerGrotesque(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFF0E8D5),
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFF0E8D5)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTickets,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFF0E8D5)),
            )
          : _tickets.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.inbox_outlined,
                        size: 64,
                        color: Color(0xFF555555),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No tickets yet",
                        style: GoogleFonts.josefinSans(
                          fontSize: 20,
                          color: const Color(0xFFB0B0B0),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Create your first support ticket",
                        style: GoogleFonts.darkerGrotesque(
                          fontSize: 16,
                          color: const Color(0xFF777777),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: const Color(0xFFD1AA10),
                  onRefresh: _loadTickets,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _tickets.length,
                    itemBuilder: (context, index) {
                      final ticket = _tickets[index];
                      return _TicketCard(
                        ticket: ticket,
                        onTap: () => _showTicketDetail(ticket),
                      );
                    },
                  ),
                ),
    );
  }

  void _showTicketDetail(Map<String, dynamic> ticket) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF252525),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle indicator
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF555555),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Subject
                Text(
                  ticket['subject'] ?? 'No subject',
                  style: GoogleFonts.josefinSans(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF0E8D5),
                  ),
                ),
                const SizedBox(height: 8),

                // Status badge
                _StatusBadge(status: ticket['status'] ?? 'OPEN'),
                const SizedBox(height: 16),

                // Created date
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Color(0xFF777777)),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(ticket['createdAt']),
                      style: GoogleFonts.darkerGrotesque(
                        fontSize: 14,
                        color: const Color(0xFF777777),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Description
                Text(
                  "Description",
                  style: GoogleFonts.josefinSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF0E8D5),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  ticket['description'] ?? 'No description',
                  style: GoogleFonts.darkerGrotesque(
                    fontSize: 15,
                    color: const Color(0xFFB0B0B0),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Responses
                if (ticket['responses'] != null && (ticket['responses'] as List).isNotEmpty) ...[
                  Text(
                    "Responses (${(ticket['responses'] as List).length})",
                    style: GoogleFonts.josefinSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFF0E8D5),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...(ticket['responses'] as List).map((response) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF3A3A3A)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.support_agent, size: 16, color: Color(0xFFD1AA10)),
                              const SizedBox(width: 8),
                              Text(
                                "Support Team",
                                style: GoogleFonts.josefinSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFD1AA10),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                _formatDate(response['respondedAt']),
                                style: GoogleFonts.darkerGrotesque(
                                  fontSize: 12,
                                  color: const Color(0xFF777777),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            response['message'] ?? '',
                            style: GoogleFonts.darkerGrotesque(
                              fontSize: 14,
                              color: const Color(0xFFB0B0B0),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ] else ...[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        "No responses yet",
                        style: GoogleFonts.darkerGrotesque(
                          fontSize: 15,
                          color: const Color(0xFF777777),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr.toString());
      return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
    } catch (e) {
      return dateStr.toString();
    }
  }
}

class _TicketCard extends StatelessWidget {
  final Map<String, dynamic> ticket;
  final VoidCallback onTap;

  const _TicketCard({
    required this.ticket,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final responseCount = (ticket['responses'] as List?)?.length ?? 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF3A3A3A)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    ticket['subject'] ?? 'No subject',
                    style: GoogleFonts.josefinSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFF0E8D5),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _StatusBadge(status: ticket['status'] ?? 'OPEN'),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              ticket['description'] ?? '',
              style: GoogleFonts.darkerGrotesque(
                fontSize: 14,
                color: const Color(0xFF999999),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  responseCount > 0 ? Icons.chat_bubble : Icons.chat_bubble_outline,
                  size: 16,
                  color: responseCount > 0 ? const Color(0xFFD1AA10) : const Color(0xFF555555),
                ),
                const SizedBox(width: 4),
                Text(
                  "$responseCount ${responseCount == 1 ? 'response' : 'responses'}",
                  style: GoogleFonts.darkerGrotesque(
                    fontSize: 13,
                    color: const Color(0xFF777777),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(ticket['createdAt']),
                  style: GoogleFonts.darkerGrotesque(
                    fontSize: 13,
                    color: const Color(0xFF777777),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr.toString());
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateStr.toString();
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status.toUpperCase()) {
      case 'OPEN':
        color = const Color(0xFF4CAF50);
        label = 'Open';
        break;
      case 'IN_PROGRESS':
        color = const Color(0xFF2196F3);
        label = 'In Progress';
        break;
      case 'RESOLVED':
        color = const Color(0xFF9C27B0);
        label = 'Resolved';
        break;
      case 'CLOSED':
        color = const Color(0xFF757575);
        label = 'Closed';
        break;
      default:
        color = const Color(0xFF777777);
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.darkerGrotesque(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}