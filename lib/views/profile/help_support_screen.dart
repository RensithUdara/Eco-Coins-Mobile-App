import 'package:eco_coins_mobile_app/utils/constants.dart';
import 'package:flutter/material.dart';

/// Help & Support Screen provides resources and assistance for users
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: ColorConstants.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header section with support message
            _buildHeader(),

            // Main content section
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Quick help section
                  _buildSection(
                    title: 'Quick Help',
                    children: [
                      _buildHelpTile(
                        title: 'How to plant a tree',
                        icon: Icons.park_outlined,
                        onTap: () => _showHelpContent(context, 'Plant a Tree'),
                      ),
                      _buildHelpTile(
                        title: 'Earning Eco Coins',
                        icon: Icons.monetization_on_outlined,
                        onTap: () => _showHelpContent(context, 'Earning Coins'),
                      ),
                      _buildHelpTile(
                        title: 'Tree maintenance',
                        icon: Icons.water_drop_outlined,
                        onTap: () =>
                            _showHelpContent(context, 'Tree Maintenance'),
                      ),
                      _buildHelpTile(
                        title: 'Account issues',
                        icon: Icons.account_circle_outlined,
                        onTap: () =>
                            _showHelpContent(context, 'Account Issues'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // FAQ section
                  _buildSection(
                    title: 'Frequently Asked Questions',
                    children: [
                      _buildExpandableFAQ(
                        question: 'How do I verify my tree planting?',
                        answer:
                            'Take a clear photo of your newly planted tree with our app. The app uses geolocation to verify the planting location. Our team reviews submissions within 24-48 hours.',
                      ),
                      _buildExpandableFAQ(
                        question: 'When do I receive my Eco Coins?',
                        answer:
                            'You receive Eco Coins immediately after your tree planting is verified. You can also earn additional coins by providing maintenance updates at regular intervals.',
                      ),
                      _buildExpandableFAQ(
                        question: 'Can I transfer Eco Coins to others?',
                        answer:
                            'Currently, Eco Coins cannot be transferred between accounts. This feature may be available in future updates.',
                      ),
                      _buildExpandableFAQ(
                        question: 'What can I do with my Eco Coins?',
                        answer:
                            'Eco Coins can be redeemed for various rewards including sustainable products, discount codes from our partner brands, or donations to environmental organizations.',
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Contact section
                  _buildSection(
                    title: 'Contact Us',
                    children: [
                      _buildContactOption(
                        title: 'Send us an email',
                        subtitle: 'support@ecocoins.com',
                        icon: Icons.email_outlined,
                        onTap: () => _launchEmailClient(context),
                      ),
                      _buildContactOption(
                        title: 'Live chat with support',
                        subtitle: 'Available Mon-Fri, 9AM-5PM',
                        icon: Icons.chat_bubble_outline,
                        onTap: () =>
                            _showComingSoonMessage(context, 'Live chat'),
                      ),
                      _buildContactOption(
                        title: 'Community forum',
                        subtitle: 'Join our eco-friendly community',
                        icon: Icons.forum_outlined,
                        onTap: () =>
                            _showComingSoonMessage(context, 'Community forum'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the enhanced header section with search bar and animations
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
          left: 20.0, right: 20.0, top: 24.0, bottom: 30.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorConstants.primary,
            ColorConstants.primary.withGreen(ColorConstants.primary.green - 15),
            ColorConstants.primaryDark,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Animated heading
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.support_agent,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'How can we help you?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Animated subtitle
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1000),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: child,
              );
            },
            child: Text(
              'Find answers to common questions or get in touch with our support team',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                letterSpacing: 0.2,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Search bar with animation
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search for help topics...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  prefixIcon:
                      const Icon(Icons.search, color: ColorConstants.primary),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  suffixIcon: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ColorConstants.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.mic_none_rounded,
                      color: ColorConstants.primary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a section with a title and children widgets
  Widget _buildSection(
      {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ColorConstants.primaryDark,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  /// Builds an enhanced help tile with icon, title, and hover effect
  Widget _buildHelpTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    // Generate a unique but consistent color for each topic based on the title
    final Color iconBgColor = Color.fromARGB(
      255,
      (icon.codePoint * 41) % 100 + 155, // Red component (155-255)
      (icon.codePoint * 59) % 80 + 175, // Green component (175-255)
      (icon.codePoint * 83) % 100 + 155, // Blue component (155-255)
    );

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.96, end: 1.0),
      duration: const Duration(milliseconds: 350),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: iconBgColor.withOpacity(0.15),
              blurRadius: 8,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              iconBgColor.withOpacity(0.05),
            ],
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            splashColor: iconBgColor.withOpacity(0.1),
            highlightColor: iconBgColor.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Animated icon with custom background
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: iconBgColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      icon,
                      color: iconBgColor.withOpacity(0.8),
                      size: 26,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Title with enhanced typography
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),

                  // Arrow with container background
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: ColorConstants.primary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds an expandable FAQ item
  /// Builds an enhanced expandable FAQ item with animations
  Widget _buildExpandableFAQ({
    required String question,
    required String answer,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        // Custom theme to override the expansion tile styling
        data: ThemeData(
          dividerColor: Colors.transparent,
          colorScheme: const ColorScheme.light(
            primary: ColorConstants.primary,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ExpansionTile(
            backgroundColor: Colors.white,
            collapsedBackgroundColor: Colors.white,
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                children: [
                  // Question mark icon with rotating animation
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: 0.8 + (0.2 * value),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            color: ColorConstants.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.question_mark_rounded,
                            color: ColorConstants.primary,
                            size: 18,
                          ),
                        ),
                      );
                    },
                  ),

                  // Question text
                  Expanded(
                    child: Text(
                      question,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ColorConstants.textPrimary,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            iconColor: ColorConstants.primary,
            collapsedIconColor: ColorConstants.primary.withOpacity(0.7),
            childrenPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Line divider
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0, top: 4.0),
                child: Container(
                  height: 1,
                  color: Colors.grey.withOpacity(0.1),
                ),
              ),

              // Answer with animation
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 300),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  answer,
                  style: const TextStyle(
                    color: ColorConstants.textSecondary,
                    height: 1.6,
                    fontSize: 15,
                  ),
                ),
              ),

              // Action buttons
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Was this helpful button
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.thumb_up_alt_outlined,
                        size: 16,
                      ),
                      label: const Text('Helpful'),
                      style: TextButton.styleFrom(
                        foregroundColor: ColorConstants.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Report issue button
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.flag_outlined,
                        size: 16,
                      ),
                      label: const Text('Report'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a contact option tile
  /// Builds an enhanced contact option with visual effects
  Widget _buildContactOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    // Use a different color for each contact option based on the icon
    final Color contactColor = [
      const Color(0xFF4CAF50), // Green for email
      const Color(0xFF2196F3), // Blue for chat
      const Color(0xFFFFA000), // Amber for forum
    ][icon.codePoint % 3];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            contactColor.withOpacity(0.05),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: contactColor.withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: contactColor.withOpacity(0.1),
          highlightColor: contactColor.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Animated icon with gradient background
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        contactColor.withOpacity(0.7),
                        contactColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: contactColor.withOpacity(0.2),
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Title and subtitle with enhanced typography
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: ColorConstants.textPrimary,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: ColorConstants.textSecondary,
                          height: 1.2,
                        ),
                      ),
                      
                      // Add a "tap to connect" hint
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.touch_app,
                            size: 14,
                            color: contactColor.withOpacity(0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Tap to connect',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: contactColor.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Animated arrow icon
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(5 * (1 - value), 0),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: contactColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: contactColor,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Shows help content for a specific topic
  void _showHelpContent(BuildContext context, String topic) {
    // Content for each help topic
    Map<String, Map<String, dynamic>> helpContent = {
      'Plant a Tree': {
        'title': 'How to Plant a Tree',
        'content': [
          {
            'subtitle': 'Step 1: Choose a Location',
            'text':
                'Select a suitable location for your tree with adequate sunlight and space for root growth. Ensure the area is free from utility lines and structures.'
          },
          {
            'subtitle': 'Step 2: Prepare the Soil',
            'text':
                'Dig a hole twice as wide as the root ball but at the same depth. Loosen the soil around the edges.'
          },
          {
            'subtitle': 'Step 3: Plant the Tree',
            'text':
                'Place the tree in the hole and backfill with soil. Ensure the trunk is straight and the root flare is slightly above ground level.'
          },
          {
            'subtitle': 'Step 4: Water and Mulch',
            'text':
                'Water thoroughly and apply a 2-3 inch layer of mulch around the base, keeping it away from the trunk.'
          },
          {
            'subtitle': 'Step 5: Record in the App',
            'text':
                'Take a photo of your newly planted tree and submit it through the app for verification.'
          },
        ]
      },
      'Earning Coins': {
        'title': 'How to Earn Eco Coins',
        'content': [
          {
            'subtitle': 'Plant a Tree: ${CoinRewards.treePlanting} coins',
            'text':
                'Receive coins once your tree planting is verified by our team.'
          },
          {
            'subtitle': 'Monthly Update: ${CoinRewards.oneMonthUpdate} coins',
            'text': 'Provide a photo update of your tree after 1 month.'
          },
          {
            'subtitle':
                'Quarterly Update: ${CoinRewards.threeMonthUpdate} coins',
            'text': 'Provide a photo update after 3 months.'
          },
          {
            'subtitle': 'Biannual Update: ${CoinRewards.sixMonthUpdate} coins',
            'text': 'Provide a photo update after 6 months.'
          },
          {
            'subtitle': 'Annual Update: ${CoinRewards.oneYearUpdate} coins',
            'text': 'Provide a photo update after 1 year.'
          },
        ]
      },
      'Tree Maintenance': {
        'title': 'Tree Maintenance Tips',
        'content': [
          {
            'subtitle': 'Regular Watering',
            'text':
                'Water deeply and regularly during the first few years, especially during dry periods.'
          },
          {
            'subtitle': 'Mulching',
            'text':
                'Maintain a 2-3 inch layer of mulch around the base of the tree, extending to the drip line.'
          },
          {
            'subtitle': 'Pruning',
            'text':
                'Remove dead or damaged branches to promote healthy growth and structure.'
          },
          {
            'subtitle': 'Protection',
            'text':
                'Protect young trees from wildlife damage and extreme weather conditions.'
          },
          {
            'subtitle': 'Monitoring',
            'text': 'Check regularly for signs of pests, disease, or stress.'
          },
        ]
      },
      'Account Issues': {
        'title': 'Common Account Issues',
        'content': [
          {
            'subtitle': 'Forgot Password',
            'text':
                'Use the "Forgot Password" option on the login screen to reset your password via email.'
          },
          {
            'subtitle': 'Update Profile Information',
            'text':
                'Go to your profile page and tap the edit button to update your details.'
          },
          {
            'subtitle': 'Verification Problems',
            'text':
                'Ensure your email is verified. Check your spam folder if you haven\'t received the verification email.'
          },
          {
            'subtitle': 'Login Issues',
            'text':
                'Make sure you\'re using the correct email and password. Try clearing your app cache if problems persist.'
          },
          {
            'subtitle': 'Missing Coins',
            'text':
                'Coins may take up to 48 hours to appear in your account after verification. Contact support if they don\'t appear.'
          },
        ]
      },
    };

    // Get content for selected topic
    var topicContent = helpContent[topic];
    if (topicContent == null) return;

    // Show help content in a bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  topicContent['title'] as String,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ColorConstants.primaryDark,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Content
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  itemCount: (topicContent['content'] as List).length,
                  itemBuilder: (context, index) {
                    var item = (topicContent['content'] as List)[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['subtitle'] as String,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: ColorConstants.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['text'] as String,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: ColorConstants.textSecondary,
                            ),
                          ),
                        ],
                      ),
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

  /// Shows a coming soon message for features in development
  void _showComingSoonMessage(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: ColorConstants.info,
      ),
    );
  }

  /// Launches email client with support email
  void _launchEmailClient(BuildContext context) {
    // In a real app, this would use url_launcher to open email client
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email client would open with support@ecocoins.com'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
