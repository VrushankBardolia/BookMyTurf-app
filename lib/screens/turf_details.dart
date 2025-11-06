import 'package:book_my_turf/screens/customer/slot_selection.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../util/colors.dart';
import '../model/turf.dart';
import '../util/api.dart';

class TurfDetails extends StatefulWidget {
  final Turf turf;
  const TurfDetails({super.key, required this.turf});

  @override
  State<TurfDetails> createState() => _TurfDetailsState();
}

class _TurfDetailsState extends State<TurfDetails> {
  late ScrollController _scrollController;
  bool showTitle = false;
  double _scrollOffset = 0;

  // Launch Phone
  Future<void> _launchPhone(String phone) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phone);
    await launchUrl(launchUri);
  }

  // Launch Map
  Future<void> _launchMap(String mapLink) async {
    if (await canLaunchUrl(Uri.parse(mapLink))) {
      await launchUrl(Uri.parse(mapLink), mode: LaunchMode.externalApplication);
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double opacity = (_scrollOffset / 280).clamp(0, 1);
    if (opacity == 1.0) {
      showTitle = true;
    } else {
      showTitle = false;
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: showTitle
            ? Text(
                widget.turf.name,
                style: TextStyle(
                  color: BMTTheme.brand,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              )
            : null,
        backgroundColor: BMTTheme.background.withOpacity(opacity),
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CachedNetworkImage(
                imageUrl: "$API/turfImages/${widget.turf.image}",
                height: 320,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.black12,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.black12,
                  child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // HEADER CARD
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            BMTTheme.black,
                            BMTTheme.brand.withValues(alpha: 0.1),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.turf.name,
                            style: const TextStyle(
                              height: 1,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () {
                              final mapLink = widget.turf.mapLink;
                              if (mapLink != null && mapLink.isNotEmpty) {
                                _launchMap(mapLink);
                              }
                            },
                            child: Text(
                              "📍${widget.turf.fullAddress}",
                              style: TextStyle(
                                // fontSize: 14,
                                decoration:
                                    (widget.turf.mapLink != null &&
                                        widget.turf.mapLink!.isNotEmpty)
                                    ? TextDecoration.underline
                                    : TextDecoration.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${widget.turf.pricePerHour} per hour',
                            style: const TextStyle(
                              height: 1,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildInfoCard('Dimensions', [
                      _buildInfoRow(
                        '📏 Dimension',
                        '${widget.turf.length}ft X ${widget.turf.width}ft',
                      ),
                      _buildInfoRow(
                        '📐 Area',
                        '${widget.turf.length * widget.turf.width} sq.m',
                      ),
                    ]),
                    const SizedBox(height: 16),

                    // Timing Section
                    _buildInfoCard('Timing', [
                      _buildInfoRow('🕐 Opening', widget.turf.openingTime),
                      _buildInfoRow('🕑 Closing', widget.turf.closingTime),
                    ]),
                    const SizedBox(height: 16),

                    // AMENITIES CARD
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: BMTTheme.black,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: BMTTheme.brand.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Amenities',
                            style: TextStyle(
                              color: BMTTheme.brand,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          ...widget.turf.amenities.map(
                            (amn) =>
                                Text("• $amn", style: TextStyle(fontSize: 18)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // CONTACT CARD
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: BMTTheme.black,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: BMTTheme.brand.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Contact',
                            style: TextStyle(
                              color: BMTTheme.brand,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: () =>
                                _launchPhone(widget.turf.phone.toString()),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.phone,
                                  color: BMTTheme.brand,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '+91 ${widget.turf.phone}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // TURF OWNER CARD (if available)
                    if (widget.turf.owner != null)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: BMTTheme.black,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: BMTTheme.brand.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Turf Owner',
                              style: TextStyle(
                                color: BMTTheme.brand,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            // const SizedBox(height: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.turf.owner!.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.turf.owner!.email,
                                  style: const TextStyle(
                                    color: BMTTheme.white50,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "+91 ${widget.turf.owner!.phone.toString()}",
                                  style: const TextStyle(
                                    color: BMTTheme.white50,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 160),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SlotBooking(turf: widget.turf),
            ),
          );
        },
        backgroundColor: BMTTheme.brand,
        isExtended: true,
        extendedPadding: EdgeInsets.symmetric(horizontal: 150),
        label: Text(
          "Book turf",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: BMTTheme.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BMTTheme.brand.withOpacity(0.3), width: 1.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: BMTTheme.brand,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
