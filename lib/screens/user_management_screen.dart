import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants.dart';
import '../services/user_service.dart';
import '../components/skeleton.dart';

class UserManagementScreen extends StatefulWidget {
  final String? companyId;
  const UserManagementScreen({super.key, this.companyId});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final UserService _userService = UserService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameArController = TextEditingController();
  final TextEditingController _nameEnController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.companyId == null ? "manage_users".tr() : "manage_supervisors".tr(),
          style: const TextStyle(fontWeight: FontWeight.bold, color: kWhiteColor),
        ),
        centerTitle: true,
        backgroundColor: kSecondaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: kWhiteColor),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddUserDialog(),
        backgroundColor: kPrimaryColor,
        icon: Icon(widget.companyId == null ? Icons.person_add : Icons.assignment_ind, color: kWhiteColor),
        label: Text(
          widget.companyId == null ? "add_company".tr() : "add_supervisor".tr(),
          style: const TextStyle(color: kWhiteColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: widget.companyId == null
            ? FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'company').snapshots()
            : FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'supervisor').where('companyId', isEqualTo: widget.companyId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: 8,
              itemBuilder: (context, index) => const UserSkeleton(),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final users = snapshot.data?.docs ?? [];

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data() as Map<String, dynamic>;
              final userId = users[index].id;
              
              String name = userData['name'] ?? 'Unknown';
              if (userData['role'] == 'company') {
                name = context.locale.languageCode == 'ar' 
                  ? (userData['companyNameAr'] ?? name)
                  : (userData['companyNameEn'] ?? name);
              }
              
              final String email = userData['email'] ?? '';
              final String role = userData['role'] ?? 'user';
              final bool isBlocked = userData['status'] == "blocked";

              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: kWhiteColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: role == 'company' ? kPrimaryColor.withOpacity(0.1) : kSecondaryColor.withOpacity(0.1),
                      child: Icon(
                        role == 'company' ? Icons.business : Icons.person,
                        color: role == 'company' ? kPrimaryColor : kSecondaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(email, style: const TextStyle(color: kGreyColor, fontSize: 12)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isBlocked ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            isBlocked ? "blocked".tr() : "active".tr(),
                            style: TextStyle(
                              color: isBlocked ? Colors.red : Colors.green,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          role.tr(),
                          style: const TextStyle(color: kGreyColor, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    PopupMenuButton(
                      icon: const Icon(Icons.more_vert, color: kGreyColor),
                      onSelected: (value) async {
                        if (value == 'block') {
                          await FirebaseFirestore.instance.collection('users').doc(userId).update({
                            'status': isBlocked ? 'active' : 'blocked'
                          });
                        } else if (value == 'promote' && widget.companyId != null) {
                          await _userService.updateUserRole(userId, 'supervisor');
                        } else if (value == 'demote' && widget.companyId != null) {
                          await _userService.updateUserRole(userId, 'user');
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(value: 'block', child: Text(isBlocked ? "unblock".tr() : "block".tr())),
                        if (widget.companyId != null && role == 'user')
                          PopupMenuItem(value: 'promote', child: Text("promote_to_supervisor".tr())),
                        if (widget.companyId != null && role == 'supervisor')
                          PopupMenuItem(value: 'demote', child: Text("demote_to_user".tr())),
                        PopupMenuItem(value: 'delete', child: Text("delete".tr(), style: const TextStyle(color: Colors.red))),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddUserDialog() {
    _emailController.clear();
    _passwordController.clear();
    _nameArController.clear();
    _nameEnController.clear();
    // إذا كان الأدمن (companyId null) فالدور إجباري شركة، وإذا كان صاحب شركة فالدور إجباري مشرف
    String selectedRole = widget.companyId == null ? 'company' : 'supervisor';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 30,
            left: 20,
            right: 20,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.companyId == null ? "add_new_company".tr() : "add_new_supervisor".tr(),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kSecondaryColor),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField("email".tr(), Icons.email, controller: _emailController, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 15),
                  _buildTextField("password".tr(), Icons.lock, controller: _passwordController, isPassword: true),
                  const SizedBox(height: 15),
                  if (selectedRole == 'company') ...[
                    _buildTextField("company_name_ar".tr(), Icons.business, controller: _nameArController),
                    const SizedBox(height: 15),
                    _buildTextField("company_name_en".tr(), Icons.business, controller: _nameEnController),
                  ] else ...[
                    _buildTextField("full_name".tr(), Icons.person, controller: _nameEnController),
                  ],
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            FirebaseApp secondaryApp = await Firebase.initializeApp(
                              name: 'SecondaryApp',
                              options: Firebase.app().options,
                            );

                            UserCredential result = await FirebaseAuth.instanceFor(app: secondaryApp)
                                .createUserWithEmailAndPassword(
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                            );

                            if (selectedRole == 'company') {
                              await _userService.createCompanyProfile(
                                result.user!.uid,
                                email: _emailController.text.trim(),
                                nameAr: _nameArController.text.trim(),
                                nameEn: _nameEnController.text.trim(),
                              );
                            } else {
                              await _userService.createSupervisorProfile(
                                result.user!.uid,
                                email: _emailController.text.trim(),
                                name: _nameEnController.text.trim(),
                                companyId: widget.companyId!,
                              );
                            }

                            await secondaryApp.delete();

                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("user_created_success".tr())),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: Text("save".tr(), style: const TextStyle(color: kWhiteColor, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, IconData icon, {
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword,
      validator: (value) => value == null || value.isEmpty ? 'required'.tr() : null,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: kPrimaryColor, size: 20),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class UserSkeleton extends StatelessWidget {
  const UserSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Row(
        children: [
          Skeleton(width: 40, height: 40, borderRadius: 20),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skeleton(width: 120, height: 16),
                SizedBox(height: 8),
                Skeleton(width: 180, height: 12),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Skeleton(width: 50, height: 18, borderRadius: 10),
              SizedBox(height: 8),
              Skeleton(width: 40, height: 12),
            ],
          ),
          SizedBox(width: 10),
          Skeleton(width: 20, height: 20, borderRadius: 10),
        ],
      ),
    );
  }
}
