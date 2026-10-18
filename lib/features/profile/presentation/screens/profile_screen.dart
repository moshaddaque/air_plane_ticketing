import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _pictureUrl(String path) {
    final trimmedPath = path.trim();

    if (trimmedPath.isEmpty) return '';

    final uri = Uri.tryParse(trimmedPath);

    if (uri != null && uri.hasScheme) {
      return trimmedPath;
    }

    return Uri.parse('${ApiConstants.baseUrl}/')
        .resolve(trimmedPath)
        .toString();
  }

  Future<void> _pickAndUpload(BuildContext context) async {
    final profile = context.read<ProfileProvider>();
    final auth = context.read<AuthProvider>();

    if (profile.isUploading) return;

    profile.clearError();

    try {
      // file_picker ^13.1.0: select one image.
      final file = await FilePicker.pickFile(type: FileType.image);

      // User cancelled the picker.
      if (file == null) return;

      if (!context.mounted) return;

      // Read the selected file's bytes on demand.
      final bytes = await file.readAsBytes();

      if (bytes.isEmpty) {
        if (!context.mounted) return;

        _showMessage(
          context,
          'Could not read the selected image. Please try another image.',
          isError: true,
        );
        return;
      }

      // Maximum image size: 8 MB.
      if (bytes.length > 8 * 1024 * 1024) {
        if (!context.mounted) return;

        _showMessage(
          context,
          'Image size must be 8 MB or smaller.',
          isError: true,
        );
        return;
      }

      if (!context.mounted) return;

      final success = await profile.uploadProfilePicture(
        bytes: bytes,
        filename: file.name,
      );

      if (!context.mounted) return;

      if (!success) {
        _showMessage(
          context,
          profile.errorMessage ?? 'Profile picture upload failed.',
          isError: true,
        );
        return;
      }

      // Refresh user data after successful upload.
      final refreshed = await auth.refreshCurrentUser();

      if (!context.mounted) return;

      _showMessage(
        context,
        refreshed
            ? 'Profile picture updated successfully.'
            : 'Picture uploaded, but profile refresh failed. Please try again.',
        isError: !refreshed,
      );
    } catch (e) {
      if (!context.mounted) return;

      _showMessage(
        context,
        'Unable to select or upload the image. Please try again.',
        isError: true,
      );
    }
  }

  void _showMessage(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = context.watch<ProfileProvider>();
    final theme = Theme.of(context);
    final user = auth.user;

    if (user == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_off_outlined, size: 48),
              SizedBox(height: 12),
              Text('User profile is unavailable.', textAlign: TextAlign.center),
              SizedBox(height: 4),
              Text(
                'Please sign in again to view your profile.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final picture = user.profilePicture?.trim();
    final hasPicture = picture != null && picture.isNotEmpty;
    final pictureUrl = hasPicture ? _pictureUrl(picture) : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile header
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerLow,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 28,
                  ),
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CircleAvatar(
                            radius: 56,
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: ClipOval(
                              child: SizedBox(
                                width: 112,
                                height: 112,
                                child: pictureUrl != null
                                    ? Image.network(
                                        pictureUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Icon(
                                                Icons.person_rounded,
                                                size: 60,
                                                color:
                                                    theme.colorScheme.primary,
                                              );
                                            },
                                      )
                                    : Icon(
                                        Icons.person_rounded,
                                        size: 60,
                                        color: theme.colorScheme.primary,
                                      ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: -2,
                            bottom: 0,
                            child: Material(
                              color: theme.colorScheme.primary,
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: profile.isUploading
                                    ? null
                                    : () => _pickAndUpload(context),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: profile.isUploading
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: theme.colorScheme.onPrimary,
                                          ),
                                        )
                                      : Icon(
                                          hasPicture
                                              ? Icons.camera_alt_outlined
                                              : Icons.add_a_photo_outlined,
                                          size: 20,
                                          color: theme.colorScheme.onPrimary,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        user.fullName,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        user.email,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(
                            avatar: const Icon(Icons.badge_outlined, size: 18),
                            label: Text(user.role),
                          ),
                          Chip(
                            avatar: Icon(
                              user.isActive
                                  ? Icons.check_circle_outline
                                  : Icons.pause_circle_outline,
                              size: 18,
                            ),
                            label: Text(user.isActive ? 'Active' : 'Inactive'),
                          ),
                        ],
                      ),
                      if (profile.isUploading) ...[
                        const SizedBox(height: 16),
                        const LinearProgressIndicator(),
                        const SizedBox(height: 8),
                        Text(
                          'Uploading profile picture...',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Personal information
              Text(
                'Personal Information',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerLow,
                child: Column(
                  children: [
                    _ProfileInfoTile(
                      icon: Icons.person_outline,
                      label: 'Full Name',
                      value: user.fullName,
                    ),
                    const Divider(height: 1, indent: 60),
                    _ProfileInfoTile(
                      icon: Icons.email_outlined,
                      label: 'Email Address',
                      value: user.email,
                    ),
                    const Divider(height: 1, indent: 60),
                    _ProfileInfoTile(
                      icon: Icons.badge_outlined,
                      label: 'Account Role',
                      value: user.role,
                    ),
                    const Divider(height: 1, indent: 60),
                    _ProfileInfoTile(
                      icon: user.isActive
                          ? Icons.check_circle_outline
                          : Icons.pause_circle_outline,
                      label: 'Account Status',
                      value: user.isActive ? 'Active' : 'Inactive',
                    ),
                    if (user.createdAt != null) ...[
                      const Divider(height: 1, indent: 60),
                      _ProfileInfoTile(
                        icon: Icons.calendar_today_outlined,
                        label: 'Member Since',
                        value: user.createdAt!
                            .toLocal()
                            .toString()
                            .split(' ')
                            .first,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Change profile picture
              OutlinedButton.icon(
                onPressed: profile.isUploading
                    ? null
                    : () => _pickAndUpload(context),
                icon: Icon(
                  hasPicture ? Icons.edit_outlined : Icons.add_a_photo_outlined,
                ),
                label: Text(
                  hasPicture ? 'Change Profile Picture' : 'Add Profile Picture',
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Supported image formats depend on your device. '
                'Maximum file size: 8 MB.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      subtitle: Text(
        value,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }
}
