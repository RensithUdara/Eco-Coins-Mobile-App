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
                        onTap: () => _showHelpContent(context, 'Tree Maintenance'),
                      ),
                      _buildHelpTile(
                        title: 'Account issues',
                        icon: Icons.account_circle_outlined,
                        onTap: () => _showHelpContent(context, 'Account Issues'),
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
                        answer: 'Take a clear photo of your newly planted tree with our app. The app uses geolocation to verify the planting location. Our team reviews submissions within 24-48 hours.',
                      ),
                      _buildExpandableFAQ(
                        question: 'When do I receive my Eco Coins?',
                        answer: 'You receive Eco Coins immediately after your tree planting is verified. You can also earn additional coins by providing maintenance updates at regular intervals.',
                      ),
                      _buildExpandableFAQ(
                        question: 'Can I transfer Eco Coins to others?',
                        answer: 'Currently, Eco Coins cannot be transferred between accounts. This feature may be available in future updates.',
                      ),
                      _buildExpandableFAQ(
                        question: 'What can I do with my Eco Coins?',
                        answer: 'Eco Coins can be redeemed for various rewards including sustainable products, discount codes from our partner brands, or donations to environmental organizations.',
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
                        onTap: () => _showComingSoonMessage(context, 'Live chat'),
                      ),
                      _buildContactOption(
                        title: 'Community forum',
                        subtitle: 'Join our eco-friendly community',
                        icon: Icons.forum_outlined,
                        onTap: () => _showComingSoonMessage(context, 'Community forum'),
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

  /// Builds the header section with support message
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ColorConstants.primary,
            ColorConstants.primaryLight,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How can we help you?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find answers to common questions or get in touch with our support team',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a section with a title and children widgets
  Widget _buildSection({required String title, required List<Widget> children}) {
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

  /// Builds a help tile with icon and title
  Widget _buildHelpTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          child: Row(
            children: [
              Icon(
                icon,
                color: ColorConstants.primary,
                size: 24,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds an expandable FAQ item
  Widget _buildExpandableFAQ({
    required String question,
    required String answer,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: ColorConstants.textPrimary,
          ),
        ),
        iconColor: ColorConstants.primary,
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            answer,
            style: const TextStyle(
              color: ColorConstants.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a contact option tile
  Widget _buildContactOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ColorConstants.primaryLight.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: ColorConstants.primary,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: ColorConstants.textSecondary,
            ),
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
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
            'text': 'Select a suitable location for your tree with adequate sunlight and space for root growth. Ensure the area is free from utility lines and structures.'
          },
          {
            'subtitle': 'Step 2: Prepare the Soil',
            'text': 'Dig a hole twice as wide as the root ball but at the same depth. Loosen the soil around the edges.'
          },
          {
            'subtitle': 'Step 3: Plant the Tree',
            'text': 'Place the tree in the hole and backfill with soil. Ensure the trunk is straight and the root flare is slightly above ground level.'
          },
          {
            'subtitle': 'Step 4: Water and Mulch',
            'text': 'Water thoroughly and apply a 2-3 inch layer of mulch around the base, keeping it away from the trunk.'
          },
          {
            'subtitle': 'Step 5: Record in the App',
            'text': 'Take a photo of your newly planted tree and submit it through the app for verification.'
          },
        ]
      },
      'Earning Coins': {
        'title': 'How to Earn Eco Coins',
        'content': [
          {
            'subtitle': 'Plant a Tree: ${CoinRewards.treePlanting} coins',
            'text': 'Receive coins once your tree planting is verified by our team.'
          },
          {
            'subtitle': 'Monthly Update: ${CoinRewards.oneMonthUpdate} coins',
            'text': 'Provide a photo update of your tree after 1 month.'
          },
          {
            'subtitle': 'Quarterly Update: ${CoinRewards.threeMonthUpdate} coins',
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
            'text': 'Water deeply and regularly during the first few years, especially during dry periods.'
          },
          {
            'subtitle': 'Mulching',
            'text': 'Maintain a 2-3 inch layer of mulch around the base of the tree, extending to the drip line.'
          },
          {
            'subtitle': 'Pruning',
            'text': 'Remove dead or damaged branches to promote healthy growth and structure.'
          },
          {
            'subtitle': 'Protection',
            'text': 'Protect young trees from wildlife damage and extreme weather conditions.'
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
            'text': 'Use the "Forgot Password" option on the login screen to reset your password via email.'
          },
          {
            'subtitle': 'Update Profile Information',
            'text': 'Go to your profile page and tap the edit button to update your details.'
          },
          {
            'subtitle': 'Verification Problems',
            'text': 'Ensure your email is verified. Check your spam folder if you haven\'t received the verification email.'
          },
          {
            'subtitle': 'Login Issues',
            'text': 'Make sure you\'re using the correct email and password. Try clearing your app cache if problems persist.'
          },
          {
            'subtitle': 'Missing Coins',
            'text': 'Coins may take up to 48 hours to appear in your account after verification. Contact support if they don\'t appear.'
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