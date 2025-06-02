import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ContactUsScreen extends StatefulWidget {
  final String userEmail;

  const ContactUsScreen({super.key, required this.userEmail});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitContact() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });
      try {
        await FirebaseFirestore.instance.collection('contact_us').add({
          'email': widget.userEmail,
          'name': _nameController.text,
          'message': _messageController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Lottie.network(
                  'https://assets.lottiefiles.com/packages/lf20_jbrwojas.json',
                  width: 40,
                  height: 40,
                ),
                const SizedBox(width: 8),
                const Text('Message sent successfully!'),
              ],
            ),
            backgroundColor: const Color(0xFFD32F2F),
          ),
        );
        _nameController.clear();
        _messageController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch URL')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
        backgroundColor: const Color(0xFFD32F2F),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF5F5F5), Color(0xFFFFFFFF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// --- Company Info ---
              const Text(
                'Company Information',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.location_on, color: Colors.red),
                title: const Text('VibrantMinds Technologies Pvt. Ltd.'),
                subtitle: const Text('2nd Floor, Viva Building, Near St. Mary’s Church & Vardhman Petrol Pump, Mumbai-Bangalore Highway, Warje, Pune 411058'),
              ),
              ListTile(
                leading: const Icon(Icons.web, color: Colors.red),
                title: const Text('Website'),
                onTap: () => _launchURL('https://vibrantmindstech.com/'),
              ),
              ListTile(
                leading: const Icon(Icons.phone, color: Colors.red),
                title: const Text('9503579517'),
              ),

              /// --- Social Links ---
              const SizedBox(height: 24),
              const Text(
                'Connect with Us',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.facebook, color: Colors.blue),
                title: const Text('Facebook'),
                onTap: () => _launchURL('https://www.facebook.com/VibrantMindsTech/'),
              ),
              ListTile(
                leading: const FaIcon(FontAwesomeIcons.instagram, color: Colors.pink),
                title: const Text('Instagram'),
                onTap: () => _launchURL('https://www.instagram.com/vibrantminds_technologies/'),
              ),
              ListTile(
                leading: const Icon(Icons.telegram, color: Colors.blueAccent),
                title: const Text('Telegram'),
                onTap: () => _launchURL('https://t.me/VibrantMinds'),
              ),
              ListTile(
                leading: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green),
                title: const Text('WhatsApp Group'),
                onTap: () => _launchURL('https://chat.whatsapp.com/6Mp34ujaaJ22YOcFmlfll4'),
              ),
              ListTile(
                leading: const Icon(Icons.mail_outline, color: Colors.deepOrange),
                title: const Text('Email'),
                onTap: () => _launchURL('mailto:Vmttalent@gmail.com'),
              ),
              ListTile(
                leading: const FaIcon(FontAwesomeIcons.youtube, color: Colors.red),
                title: const Text('YouTube'),
                onTap: () => _launchURL('https://www.youtube.com/@vibrantmindsitjobscareers3793'),
              ),

              const SizedBox(height: 32),

              /// --- Contact Form ---
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Send Us a Message',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: Color(0xFF000000),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration('Your Name'),
                      validator: (value) => value!.isEmpty ? 'Enter your name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _messageController,
                      maxLines: 5,
                      decoration: _inputDecoration('Your Message'),
                      validator: (value) => value!.isEmpty ? 'Enter your message' : null,
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitContact,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD32F2F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        child: _isSubmitting
                            ? Lottie.asset('assets/animations/loading_animation.json', width: 24, height: 24)
                            : const Text(
                          'Send',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w600,
                          ),
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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontFamily: 'Roboto', color: Color(0xFFD32F2F)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
