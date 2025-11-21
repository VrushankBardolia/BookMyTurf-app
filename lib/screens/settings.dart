import 'package:book_my_turf/screens/settings/faqs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Assuming these imports define your custom widgets and theme
import '/components/input.dart';
import '/util/colors.dart'; // Assuming BMTTheme is defined here
import '/components/buttons.dart';
import '/screens/onboarding.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  // Use null-safe defaults or initialize as null
  String? type;
  String? name;
  String? email;
  String? phone;
  // State to track if loading is complete
  bool isLoading = true;

  final TextEditingController emailCont = TextEditingController();
  final TextEditingController phoneCont = TextEditingController();

  String capitalize(String str) {
    if (str.isEmpty) return "";
    return "${str[0].toUpperCase()}${str.substring(1)}";
  }

  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("type"); // Use await for async removal
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Onboarding()), (route) => false,
    );
  }

  Future<void> fetchUserDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      type = prefs.getString('type');
      name = prefs.getString('name');
      email = prefs.getString('email');
      phone = prefs.getString('phone');
      isLoading = false; // Set loading to false once data is fetched
    });
  }

  void editEmail() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      sheetAnimationStyle: AnimationStyle(curve: ElasticInOutCurve()),
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Update your Email",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Input(
              controller: emailCont,
              hint: "New Email",
              type: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            Button(text: "Save",onClick: ()=>Navigator.pop(context),),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    // Determine the user name and type, using placeholders while loading
    final displayName = name ?? 'Loading User...';
    final displayType = type != null ? capitalize(type!) : 'Type';
    final displayEmail = email ?? 'user@example.com';
    final displayPhone = phone != null ? "+91 $phone" : 'N/A';

    if (isLoading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        children: [
          // --- User Profile Header ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: BMTTheme.black, // Slightly different container color
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // Add a simple initial avatar
                CircleAvatar(
                  radius: 30,
                  backgroundColor: BMTTheme.brand,
                  child: Text(
                    displayName.isNotEmpty ? displayName[0] : 'U',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: BMTTheme.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(displayName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(displayType,
                      style: TextStyle(
                        color: BMTTheme.brand, // Highlight the user type
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // -----------------------------------------------------------------
          // ### Account Details
          // -----------------------------------------------------------------
          const Text("Account Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),

          accountTile(
            title: 'Email',
            value: displayEmail,
            icon: CupertinoIcons.mail,
          ),

          accountTile(
            title: 'Phone number',
            value: displayPhone,
            icon: CupertinoIcons.phone,
          ),

          // -----------------------------------------------------------------
          // ### Support & Legal
          // -----------------------------------------------------------------
          const SizedBox(height: 24),
          const Text("Support & Legal",style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),

          settingTile('FAQs', CupertinoIcons.question, FAQs()),
          settingTile('Terms and conditions', CupertinoIcons.doc_text, FAQs()),
          settingTile('Privacy Policy', CupertinoIcons.shield, FAQs()),
          settingTile('About Us', CupertinoIcons.info, FAQs()),


          // -----------------------------------------------------------------
          // --- Logout Button ---
          // -----------------------------------------------------------------
          const SizedBox(height: 32),
          Button(
            text: "Logout",
            onClick: logout,
            backColor: CupertinoColors.destructiveRed,
            textColor: Colors.white,
            // borderRadius: BorderRadius.circular(12),
          ),

          // --- Footer ---
          const SizedBox(height: 32),
          Text("from\n& for\nsurat".toUpperCase(),
            style: TextStyle(
              color: BMTTheme.black50,
              fontWeight: FontWeight.w900,
              height: 0.8,
              fontSize: 60,
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  // Helper widget to build the setting item (replaces the original container)
  Widget accountTile({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: BMTTheme.black, // Dark container background
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: BMTTheme.brand), // Use a colored icon
        title: Text(title, style: TextStyle(color: BMTTheme.white50)),
        subtitle: Text(value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  // Updated settingTile to support optional subtitle
  Widget settingTile(String title, IconData icon, Widget secondScreen) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: BMTTheme.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(title),
        leading: Icon(icon, color: BMTTheme.brand),
        trailing: const Icon(CupertinoIcons.chevron_right, size: 18),
        onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>secondScreen)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}