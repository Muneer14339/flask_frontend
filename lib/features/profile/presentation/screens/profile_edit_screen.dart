import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../domain/entities/user_profile.dart';
import '../bloc/profile_bloc.dart';


class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;

  ProfileEntity? _currentProfile;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  void _populateFields(ProfileEntity profile) {
    _currentProfile = profile;
    _fullNameController.text = profile.fullName;
    _emailController.text = profile.email;
    _phoneController.text = profile.phone ?? '';
    _cityController.text = profile.city ?? '';
    _stateController.text = profile.state ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: isDark ? AppColors.primaryDark : AppColors.primary,
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            _populateFields(state.profile);
          } else if (state is ProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context);
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.accent,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
          child: Form(
          key: _formKey,
          child: Column(
          children: [
          CustomTextField(
          controller: _fullNameController,
          label: 'Full Name',
          hintText: 'Enter your full name',
          prefixIcon: Icons.person_outline,
          validator: (value) {
          if (value == null || value.isEmpty) {
          return 'Please enter your full name';
          }
          return null;
          },
          ),
          const SizedBox(height: 16),
          CustomTextField(
          controller: _emailController,
          label: 'Email',
          hintText: 'Enter your email',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Email is required';
            final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');
            if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
            return null;
        },
      ),
      const SizedBox(height: 16),
      CustomTextField(
        controller: _phoneController,
        label: 'Phone Number',
        hintText: 'Enter your phone number',
        prefixIcon: Icons.phone_outlined,
        keyboardType: TextInputType.phone,
      ),
      const SizedBox(height: 16),
      CustomTextField(
        controller: _cityController,
        label: 'City',
        hintText: 'Enter your city',
        prefixIcon: Icons.location_city_outlined,
      ),
      const SizedBox(height: 16),
      CustomTextField(
        controller: _stateController,
        label: 'State',
        hintText: 'Enter your state',
        prefixIcon: Icons.map_outlined,
      ),
      const SizedBox(height: 32),
      Row(
        children: [
          Expanded(
            child: CustomButton(
              text: 'Cancel',
              isOutlined: true,
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CustomButton(
              text: 'Save Changes',
              isLoading: state is ProfileLoading,
              onPressed: () => _saveProfile(),
            ),
          ),
        ],
      ),
      ],
    ),
    ),
    );
  },
  ),
  );
}

void _saveProfile() {
  if (_formKey.currentState!.validate() && _currentProfile != null) {
    final updatedProfile = _currentProfile!.copyWith(
      fullName: _fullNameController.text,
      email: _emailController.text,
      phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
      city: _cityController.text.isNotEmpty ? _cityController.text : null,
      state: _stateController.text.isNotEmpty ? _stateController.text : null,
    );

    context.read<ProfileBloc>().add(UpdateProfileEvent(updatedProfile));
  }
}
}