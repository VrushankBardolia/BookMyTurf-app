import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:book_my_turf/util/colors.dart';

class FAQs extends StatelessWidget {
  const FAQs({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> faqs = [
      {
        "question":"1. How do I book a turf?",
        "answer":"To book a turf, open the turf details page → select your preferred date → choose start & end time slots → confirm your booking → pay the advance amount to secure your slot.",
      },
      {
        "question":"2. Can I cancel or modify my booking?",
        "answer":"Currently, bookings cannot be modified once confirmed. For cancellations, please contact the turf owner directly using the phone number provided in the Turf Details section.",
      },
      {
        "question": "3. What happens if I don’t complete the payment?",
        "answer": "If the payment isn’t completed, the booking will not be considered valid. Your time slot will remain available for other users until the payment succeeds.",
      },
      {
        "question": "4. What if no UPI app is found on my device?",
        "answer": "If no UPI app is detected, you won’t be able to complete the payment. Please install a UPI app like Google Pay, PhonePe, BHIM, or Paytm to proceed.",
      },
      {
        "question": "5. Can I book multiple time slots at once?",
        "answer": "Yes. Simply select a start time and an end time. The system calculates the duration and total price automatically."
      },
      {
        "question": "6. How quickly does booking information update?",
        "answer": "Booking status is updated instantly after successful payment and confirmation. You will see the new booking in your My Bookings screen.",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Frequently Asked Questions"),
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ...faqs.map((faq)=>QnA("${faq["question"]}", "${faq["answer"]}")),
              // SizedBox(height: 20,)
            ],
          ),
        ),
      ),
    );
  }

  Widget QnA(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BMTTheme.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BMTTheme.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // QUESTION MARK ICON
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: BMTTheme.brand.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(CupertinoIcons.question, color: BMTTheme.brand,),
          ),
          const SizedBox(width: 20),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // QUESTION
                Text(question,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white, // High emphasis
                    height: 1.2, // Better line height for multi-line titles
                  ),
                ),
                const SizedBox(height: 4),

                // ANSWER
                Text(answer,
                  textAlign: TextAlign.left, // Justify can create weird gaps on mobile
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5, // Crucial for readability of long text
                    fontWeight: FontWeight.w400,
                    color: BMTTheme.white.withValues(alpha: 0.8), // Medium emphasis
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
