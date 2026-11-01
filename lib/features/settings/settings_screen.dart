import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wefamily/l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/config.dart';
import '../../core/services/media_service.dart';
import '../../core/services/tracking_service.dart';
import '../../core/theme/colors.dart';
import '../../core/utils/circle_providers.dart';
import '../../core/utils/session_provider.dart';
import '../../core/widgets/ahl_card.dart';
import '../../core/widgets/avatar_circle.dart';
import '../../core/widgets/icon_3d.dart';
import '../../core/widgets/language_switcher.dart';
import '../circle/circle_management_screen.dart';
import '../circle/circle_screen.dart';
import '../location/location_permission_sheet.dart';
import '../notifications/notifications_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _sharing = true;
  bool _ghost = false;
  bool _uploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final session = ref.read(sessionProvider);
      if (session.isLoggedIn && session.user == null) {
        ref.read(sessionProvider.notifier).syncWithBackend();
      }
    });
  }

  User? get _authUser {
    try {
      return FirebaseAuth.instance.currentUser;
    } catch (_) {
      return null;
    }
  }

  Future<void> _changePhoto(AppLocalizations l10n) async {
    if (_uploadingPhoto) return;
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 90,
    );
    if (picked == null) return;
    setState(() => _uploadingPhoto = true);
    try {
      final url = await const MediaService().uploadProfilePhoto(
        File(picked.path),
      );
      await ref.read(sessionProvider.notifier).updateProfile(photoUrl: url);
    } catch (error) {
      if (!mounted) return;
      final message = error is MediaUploadException
          ? error.message
          : l10n.error;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionProvider);
    final user = session.user;
    final authUser = _authUser;
    final authEmail = authUser?.email ?? '';
    final authLocal = authEmail.contains('@')
        ? authEmail.split('@').first
        : authEmail;
    final uid = ref.watch(currentUidProvider);
    String? memberName;
    for (final member in ref.watch(liveMembersProvider)) {
      if (member.uid == uid) {
        memberName = member.name;
        break;
      }
    }
    final email = (user?.phone.trim().isNotEmpty ?? false)
        ? user!.phone
        : authEmail;
    final memberTrim = memberName?.trim() ?? '';
    final sessionName = user?.name.trim() ?? '';
    final authDisplay = authUser?.displayName?.trim() ?? '';
    final genericSessionName =
        sessionName.isEmpty ||
        sessionName == authLocal ||
        sessionName == authEmail;
    final name = !genericSessionName
        ? sessionName
        : (memberTrim.isNotEmpty
              ? memberTrim
              : (authDisplay.isNotEmpty
                    ? authDisplay
                    : (sessionName.isNotEmpty
                          ? sessionName
                          : (authLocal.isNotEmpty ? authLocal : l10n.you))));
    final tracking = ref.watch(trackingControllerProvider);
    final bool sharing = AppConfig.useMockData ? _sharing : tracking.enabled;
    final bool ghost = AppConfig.useMockData ? _ghost : tracking.ghost;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        actions: const [LanguageSwitcher(compact: true), SizedBox(width: 16)],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AhlCard(
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _uploadingPhoto ? null : () => _changePhoto(l10n),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AvatarCircle(
                          name: name,
                          photoUrl: user?.photoUrl ?? authUser?.photoURL,
                          size: 56,
                        ),
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AhlColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: _uploadingPhoto
                                ? const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.camera_alt_rounded,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email.isEmpty ? '—' : email,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AhlColors.inkMedium),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AhlCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon3D('bell', size: 30),
                    title: Text(l10n.notifications),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const NotificationsScreen(),
                        ),
                      );
                    },
                  ),
                  if (session.hasCircle) ...[
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    ListTile(
                      leading: const Icon3D('folder-new', size: 30),
                      title: Text(l10n.manageCircle),
                      subtitle: session.circle == null
                          ? null
                          : Text(
                              session.circle!.name,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AhlColors.inkMedium),
                            ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => const CircleManagementScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    ListTile(
                      leading: const Icon3D('link', size: 30),
                      title: Text(l10n.joinAnotherCircle),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => const CircleScreen(addMode: true),
                          ),
                        );
                      },
                    ),
                  ],
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  SwitchListTile(
                    secondary: const Icon3D('map-pin', size: 30),
                    title: Text(l10n.locationSharing),
                    subtitle: Text(
                      l10n.locationSharingSub,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: AhlColors.inkMedium),
                    ),
                    value: sharing,
                    activeThumbColor: AhlColors.primary,
                    onChanged: (v) async {
                      if (AppConfig.useMockData) {
                        setState(() => _sharing = v);
                        return;
                      }
                      final controller = ref.read(
                        trackingControllerProvider.notifier,
                      );
                      if (!v) {
                        await controller.pause();
                        return;
                      }
                      if (tracking.foregroundGranted) {
                        await controller.resume();
                      } else if (context.mounted) {
                        await showLocationPermissionSheet(context);
                      }
                    },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  SwitchListTile(
                    secondary: const Icon3D('ghost', size: 30),
                    title: Text(l10n.ghostMode),
                    subtitle: Text(
                      l10n.ghostModeSub,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: AhlColors.inkMedium),
                    ),
                    value: ghost,
                    activeThumbColor: AhlColors.primary,
                    onChanged: (v) async {
                      if (AppConfig.useMockData) {
                        setState(() => _ghost = v);
                        return;
                      }
                      await ref
                          .read(trackingControllerProvider.notifier)
                          .setGhost(v);
                    },
                  ),
                  if (!AppConfig.useMockData) ...[
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    ListTile(
                      leading: const Icon3D('wifi', size: 30),
                      title: Text(l10n.backgroundTipsTitle),
                      subtitle: Text(
                        l10n.backgroundTipsBody,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: AhlColors.inkMedium),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => showLocationPermissionSheet(context),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            AhlCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.logout, color: AhlColors.danger),
                title: Text(
                  l10n.logout,
                  style: const TextStyle(color: AhlColors.danger),
                ),
                onTap: () async {
                  try {
                    await ref
                        .read(trackingControllerProvider.notifier)
                        .stop()
                        .timeout(const Duration(seconds: 2));
                  } catch (_) {}
                  try {
                    await FirebaseAuth.instance.signOut();
                  } catch (_) {
                    // ignore when Firebase is unavailable
                  }
                  await ref.read(sessionProvider.notifier).logout();
                  if (context.mounted) context.go('/login');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
