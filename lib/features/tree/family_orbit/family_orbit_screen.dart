import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/colors.dart';
import '../../../core/utils/circle_providers.dart';
import '../../../core/utils/session_provider.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/tree_repository.dart';
import '../../tree/add_relative_sheet.dart';
import '../../tree/person_profile_screen.dart';
import '../../tree/tree_providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'family_orbit_avatars.dart';
import 'family_orbit_layout.dart';
import 'family_orbit_model.dart';

class FamilyOrbitScreen extends ConsumerStatefulWidget {
  const FamilyOrbitScreen({super.key});

  @override
  ConsumerState<FamilyOrbitScreen> createState() => _FamilyOrbitState();
}

class _FamilyOrbitState extends ConsumerState<FamilyOrbitScreen>
    with TickerProviderStateMixin {
  late final AnimationController _motion;
  late final AnimationController _sonar;
  late final AnimationController _pulse;
  late final AnimationController _sheet;
  late final AnimationController _draw;
  late final AnimationController _confetti;
  late final AnimationController _wave;

  String? _focusId;
  String _ensuredCircleId = '';
  Offset? _confettiOrigin;
  Offset? _waveOrigin;
  _ToastState? _toast;
  bool _ensuring = false;

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _sonar = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _sheet = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _draw = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _confetti = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    _wave = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
  }

  void _scheduleEnsureSelf(FamilyCircle circle, String uid) {
    if (_ensuredCircleId == circle.id || _ensuring) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _ensuredCircleId == circle.id || _ensuring) return;
      _ensureSelf(circle, uid);
    });
  }

  Future<void> _ensureSelf(FamilyCircle circle, String uid) async {
    _ensuring = true;
    try {
      final members = ref.read(liveMembersProvider);
      CircleMember? self;
      for (final member in members) {
        if (member.uid == uid) {
          self = member;
          break;
        }
      }
      final session = ref.read(sessionProvider).user;
      final name = (self?.name ?? session?.name ?? '').trim();
      if (name.isEmpty) return;
      await ref
          .read(treeRepositoryProvider)
          .ensureSelfNode(
            circleId: circle.id,
            uid: uid,
            name: name,
            photoUrl: self?.photoUrl ?? session?.photoUrl,
          );
      _ensuredCircleId = circle.id;
    } catch (_) {
      // Retried when this screen rebuilds.
    } finally {
      _ensuring = false;
    }
  }

  Future<void> _addRelative(String kind) async {
    final l10n = AppLocalizations.of(context);
    final circle = ref.read(myCircleProvider).value;
    final uid = ref.read(currentUidProvider);
    final focusId = _focusId;
    if (circle == null || uid == null || focusId == null) return;
    final persons = ref.read(treePersonsProvider).value ?? const <TreePerson>[];
    final byId = <String, TreePerson>{for (final p in persons) p.id: p};
    final anchor = byId[focusId];
    if (anchor == null) return;

    if (kind == 'parent' && anchor.parentIds.length >= 2) {
      _showToast(l10n.alreadyTwoParents, 'err');
      return;
    }
    if (kind == 'partner' && anchor.spouseId != null) {
      _showToast(l10n.partnerAlready, 'err');
      return;
    }
    if (kind == 'sibling' && anchor.parentIds.isEmpty) {
      _showToast(l10n.treeSiblingNeedsParent, 'err');
      return;
    }

    final existingParent = anchor.parentIds.isEmpty
        ? null
        : byId[anchor.parentIds.first];
    final initialRelation = switch (kind) {
      'parent' => existingParent?.gender == 'male' ? 'mother' : 'father',
      'partner' => anchor.gender == 'male' ? 'wife' : 'husband',
      'sibling' => 'brother',
      'child' => 'son',
      _ => null,
    };
    final draft = await showAddRelativeSheet(
      context,
      anchor: anchor,
      circleMembers: ref.read(liveMembersProvider),
      persons: persons,
      selfUid: uid,
      initialRelation: initialRelation,
    );
    if (draft == null || !mounted) return;

    try {
      final repo = ref.read(treeRepositoryProvider);
      final created = await repo.addRelative(
        circleId: circle.id,
        uid: uid,
        anchor: anchor,
        name: draft.name,
        relation: draft.relation,
        gender: draft.gender,
        birthDate: draft.birthDate,
        photoUrl: draft.photoUrl,
        about: draft.about,
        linkedUid: draft.linkedUid,
      );
      if ((draft.relation == 'father' || draft.relation == 'mother') &&
          anchor.parentIds.isNotEmpty) {
        await repo.linkSpouses(
          circleId: circle.id,
          aId: created.id,
          bId: anchor.parentIds.first,
        );
      }
      if (!mounted) return;
      _confettiOrigin = _stagePosition(anchor.id);
      _confetti.forward(from: 0);
      setState(() => _focusId = created.id);
      _showToast(l10n.personAdded(created.name), 'ok');
    } on TreeException catch (e) {
      if (!mounted) return;
      _showToast(
        e.code == 'member-already-linked'
            ? l10n.memberAlreadyLinked
            : l10n.treeSaveError,
        'err',
      );
    } catch (_) {
      if (!mounted) return;
      _showToast(l10n.treeSaveError, 'err');
    }
  }

  Future<void> _openProfile() async {
    final focusId = _focusId;
    if (focusId == null) return;
    final persons = ref.read(treePersonsProvider).value ?? const <TreePerson>[];
    for (final person in persons) {
      if (person.id != focusId) continue;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PersonProfileScreen(person: person),
        ),
      );
      return;
    }
  }

  void _showToast(String message, String kind) {
    setState(() {
      _toast = _ToastState(message: message, kind: kind, show: true);
    });
    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      setState(
        () => _toast = _toast == null
            ? null
            : _ToastState(
                message: _toast!.message,
                kind: _toast!.kind,
                show: false,
              ),
      );
      _toastTimer = Timer(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _toast = null);
      });
    });
  }

  Timer? _toastTimer;

  Offset _stagePosition(String id) {
    final size = MediaQuery.sizeOf(context);
    final people = _orbitPeople;
    final focus = _focusId ?? (people.isNotEmpty ? people.keys.first : id);
    final layout = orbitLayout(
      people: people,
      focusId: focus,
      size: size,
      rtl: _rtl,
    );
    return layout.positions[id] ?? Offset.zero;
  }

  void _setFocus(String id) {
    if (_focusId == id) return;
    setState(() => _focusId = id);
    _waveOrigin = _stagePosition(id);
    _wave.forward(from: 0);
  }

  bool get _rtl {
    final direction = Directionality.of(context);
    return direction == TextDirection.rtl;
  }

  Map<String, OrbitPerson> get _orbitPeople {
    final persons = ref.read(treePersonsProvider).value ?? const <TreePerson>[];
    return _orbitFrom(persons, ref.read(liveMembersProvider));
  }

  Map<String, OrbitPerson> _orbitFrom(
    List<TreePerson> persons,
    List<CircleMember> members,
  ) {
    final photos = <String, String>{
      for (final member in members)
        if (member.photoUrl != null && member.photoUrl!.trim().isNotEmpty)
          member.uid: member.photoUrl!.trim(),
    };
    String? photoFor(TreePerson person) {
      final live = person.linkedUid == null ? null : photos[person.linkedUid];
      if (live != null && live.isNotEmpty) return live;
      final own = person.photoUrl?.trim();
      return own == null || own.isEmpty ? null : own;
    }

    return <String, OrbitPerson>{
      for (final person in persons)
        person.id: OrbitPerson.fromTree(person)
            .copyWith(photoUrl: photoFor(person)),
    };
  }

  String? _selfNodeId(List<TreePerson> persons, String? uid) {
    if (uid == null) return null;
    for (final person in persons) {
      if (person.linkedUid == uid) return person.id;
    }
    return uid;
  }

  String _relationLabel(String rel, AppLocalizations l10n) {
    switch (rel) {
      case 'Parent':
        return l10n.relationParent;
      case 'Partner':
        return l10n.relationPartner;
      case 'Child':
        return l10n.relationChild;
      case 'Sibling':
        return l10n.relationSibling;
      case 'Grandparent':
        return l10n.relationGrandparent;
      case 'Grandchild':
        return l10n.relationGrandchild;
      default:
        return l10n.relationRelative;
    }
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    _motion.dispose();
    _sonar.dispose();
    _pulse.dispose();
    _sheet.dispose();
    _draw.dispose();
    _confetti.dispose();
    _wave.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final uid = ref.watch(currentUidProvider);
    final circle = ref.watch(myCircleProvider).value;
    final persons = ref.watch(treePersonsValueProvider);
    final members = ref.watch(liveMembersProvider);
    final orbit = _orbitFrom(persons, members);
    final treeById = <String, TreePerson>{for (final p in persons) p.id: p};
    if (circle != null && uid != null) {
      _scheduleEnsureSelf(circle, uid);
    }
    final focus = _focusId;
    final selfId = _selfNodeId(persons, uid);
    final focusId = focus != null && orbit.containsKey(focus)
        ? focus
        : (selfId != null && orbit.containsKey(selfId)
              ? selfId
              : (orbit.isEmpty ? null : orbit.keys.first));
    if (_focusId == null && focusId != null) {
      // Set initial focus outside the build frame via post-frame callback.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _focusId == null) setState(() => _focusId = focusId);
      });
    }
    final focusPerson = focusId != null ? orbit[focusId] : null;

    final stageConstraints = LayoutBuilder(
      builder: (_, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        if (size.isEmpty) return const SizedBox.shrink();
        final layout = orbitLayout(
          people: orbit,
          focusId: focusId ?? '',
          size: size,
          rtl: _rtl,
        );
        return _Stage(
          layout: layout,
          orbit: orbit,
          treeById: treeById,
          focusId: focusId ?? '',
          selfId: selfId ?? '',
          l10n: l10n,
          motion: _motion,
          sonar: _sonar,
          draw: _draw,
          confetti: _confetti,
          confettiOrigin: _confettiOrigin,
          wave: _wave,
          waveOrigin: _waveOrigin,
          onNodeTap: _setFocus,
          pulse: _pulse,
        );
      },
    );

    return Scaffold(
      backgroundColor: AhlColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              _Header(
                l10n: l10n,
                count: orbit.length,
                focusPerson: focusPerson,
                selfId: selfId,
                onBackToMe: () {
                  if (selfId != null && _focusId != selfId) {
                    _setFocus(selfId);
                  }
                },
              ),
              Expanded(child: stageConstraints),
              _Sheet(
                l10n: l10n,
                sheet: _sheet,
                focusId: focusId ?? '',
                selfId: selfId ?? '',
                orbit: orbit,
                treeById: treeById,
                onAdd: _addRelative,
                onEdit: _openProfile,
                relationLabel: (rel) => _relationLabel(rel, l10n),
              ),
            ],
          ),
          if (_toast != null && _toast!.show)
            Positioned(
              top: 70,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: _toast!.show ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 260),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _toastKindColor(_toast!.kind),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _toast!.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _toastKindColor(String kind) {
    switch (kind) {
      case 'ok':
        return AhlColors.success;
      case 'err':
        return AhlColors.danger;
      default:
        return AhlColors.ink;
    }
  }
}

class _ToastState {
  const _ToastState({
    required this.message,
    required this.kind,
    required this.show,
  });
  final String message;
  final String kind;
  final bool show;
}

class _Header extends StatelessWidget {
  const _Header({
    required this.l10n,
    required this.count,
    required this.focusPerson,
    required this.selfId,
    required this.onBackToMe,
  });

  final AppLocalizations l10n;
  final int count;
  final OrbitPerson? focusPerson;
  final String? selfId;
  final VoidCallback onBackToMe;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AhlColors.background,
      padding: EdgeInsets.fromLTRB(
        18,
        MediaQuery.of(context).padding.top + 14,
        18,
        4,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _GradientTitle(text: l10n.familyOrbitTitle),
                const SizedBox(height: 2),
                Text(
                  l10n.membersRecenter(count),
                  style: TextStyle(
                    fontSize: 12,
                    color: AhlColors.muted,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _HomeButton(onTap: onBackToMe, label: l10n.backToMe),
        ],
      ),
    );
  }
}

class _GradientTitle extends StatefulWidget {
  const _GradientTitle({required this.text});
  final String text;

  @override
  State<_GradientTitle> createState() => _GradientTitleState();
}

class _GradientTitleState extends State<_GradientTitle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 5))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) {
        final t = _c.value;
        final s1 = (t - 0.25).clamp(0.0, 1.0);
        final s2 = t.clamp(0.0, 1.0);
        final s3 = (t + 0.25).clamp(0.0, 1.0);
        return ShaderMask(
          shaderCallback: (rect) => LinearGradient(
            colors: [AhlColors.ink, AhlColors.primary, AhlColors.ink],
            stops: [s1, s2, s3],
          ).createShader(rect),
          blendMode: BlendMode.srcIn,
          child: child,
        );
      },
      child: Text(
        widget.text,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
          height: 1.1,
        ),
      ),
    );
  }
}

class _HomeButton extends StatelessWidget {
  const _HomeButton({required this.onTap, required this.label});
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: AhlColors.orbitPrimaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AhlColors.primary.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.my_location_rounded,
            size: 19,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _Sheet extends StatelessWidget {
  const _Sheet({
    required this.l10n,
    required this.sheet,
    required this.focusId,
    required this.selfId,
    required this.orbit,
    required this.treeById,
    required this.onAdd,
    required this.onEdit,
    required this.relationLabel,
  });

  final AppLocalizations l10n;
  final AnimationController sheet;
  final String focusId;
  final String selfId;
  final Map<String, OrbitPerson> orbit;
  final Map<String, TreePerson> treeById;
  final ValueSetter<String> onAdd;
  final VoidCallback onEdit;
  final String Function(String) relationLabel;

  @override
  Widget build(BuildContext context) {
    final person = orbit[focusId];
    if (person == null) return const SizedBox.shrink();
    final rel = orbitRelation(
      people: orbit,
      id: focusId,
      focusId: selfId,
      selfId: selfId,
    );
    final showYou = focusId == selfId;
    final relationText = showYou
        ? l10n.you
        : l10n.yourRelation(relationLabel(rel));
    final treePerson = treeById[focusId];
    final parents = treePerson?.parentIds.length ?? person.parents.length;
    final sibs = _siblingsCount(orbit, focusId);
    final kids = _kidsCount(orbit, treePerson, selfId);

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1.1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: sheet, curve: Curves.easeOutCubic)),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AhlColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          boxShadow: AhlColors.sheetShadow,
        ),
        padding: EdgeInsets.fromLTRB(
          18,
          10,
          18,
          16 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: AhlColors.line,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _SheetAvatar(person: person),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        person.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AhlColors.ink,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        relationText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AhlColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: l10n.editPerson,
                  onPressed: treePerson == null ? null : onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 19),
                  color: AhlColors.primary,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatChip(label: l10n.parents, value: parents),
                _StatChip(label: l10n.siblings, value: sibs),
                _StatChip(label: l10n.children, value: kids),
              ],
            ),
            const SizedBox(height: 12),
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 2.6,
              ),
              children: [
                _AddTile(
                  kind: 'parent',
                  label: l10n.addParent,
                  gradient: AhlColors.orbitPrimaryGradient,
                  textColor: Colors.white,
                  onTap: () => onAdd('parent'),
                ),
                _AddTile(
                  kind: 'sibling',
                  label: l10n.addSibling,
                  gradient: AhlColors.orbitPrimaryGradient,
                  textColor: Colors.white,
                  onTap: () => onAdd('sibling'),
                ),
                _AddTile(
                  kind: 'partner',
                  label: l10n.addPartner,
                  gradient: AhlColors.orbitGoldGradient,
                  textColor: AhlColors.ink,
                  onTap: () => onAdd('partner'),
                ),
                _AddTile(
                  kind: 'child',
                  label: l10n.addChild,
                  gradient: AhlColors.orbitPrimaryGradient,
                  textColor: Colors.white,
                  onTap: () => onAdd('child'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int _siblingsCount(Map<String, OrbitPerson> orbit, String id) {
    final person = orbit[id];
    if (person == null) return 0;
    return orbit.values
        .where(
          (p) => p.id != id && p.parents.any((x) => person.parents.contains(x)),
        )
        .length;
  }

  int _kidsCount(
    Map<String, OrbitPerson> orbit,
    TreePerson? tp,
    String selfId,
  ) {
    if (tp == null) return 0;
    final spouse = tp.spouseId;
    return orbit.values.where((p) {
      if (p.id == tp.id) return false;
      if (p.parents.contains(tp.id)) return true;
      if (spouse != null && p.parents.contains(spouse)) return true;
      return false;
    }).length;
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: AhlColors.orbitChip,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$value',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AhlColors.ink,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AhlColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({
    required this.kind,
    required this.label,
    required this.gradient,
    required this.textColor,
    required this.onTap,
  });
  final String kind;
  final String label;
  final Gradient gradient;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AhlColors.primary.withValues(alpha: 0.28),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

class _SheetAvatar extends StatelessWidget {
  const _SheetAvatar({required this.person});
  final OrbitPerson person;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AhlColors.orbitChip,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: ClipOval(
        child: _orbitAvatarFace(person, 52, _orbitHash(person.id) % 4),
      ),
    );
  }
}

Widget _orbitAvatarFace(OrbitPerson person, double size, int index) {
  final fallback = SvgPicture.string(
    orbitAvatarSvg(person.type, index),
    width: size,
    height: size,
    fit: BoxFit.contain,
  );
  final photo = person.photoUrl?.trim();
  if (photo == null || photo.isEmpty) return fallback;
  return Image.network(
    photo,
    width: size,
    height: size,
    fit: BoxFit.cover,
    frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
      if (wasSynchronouslyLoaded || frame != null) return child;
      return fallback;
    },
    errorBuilder: (context, error, stackTrace) => fallback,
  );
}

class _Stage extends StatelessWidget {
  const _Stage({
    required this.layout,
    required this.orbit,
    required this.treeById,
    required this.focusId,
    required this.selfId,
    required this.l10n,
    required this.motion,
    required this.sonar,
    required this.draw,
    required this.confetti,
    required this.confettiOrigin,
    required this.wave,
    required this.waveOrigin,
    required this.onNodeTap,
    required this.pulse,
  });

  final OrbitLayoutResult layout;
  final Map<String, OrbitPerson> orbit;
  final Map<String, TreePerson> treeById;
  final String focusId;
  final String selfId;
  final AppLocalizations l10n;
  final AnimationController motion;
  final AnimationController sonar;
  final AnimationController draw;
  final AnimationController confetti;
  final Offset? confettiOrigin;
  final AnimationController wave;
  final Offset? waveOrigin;
  final ValueSetter<String> onNodeTap;
  final AnimationController pulse;

  void _handleTap(PointerUpEvent event) {
    String? nearest;
    var nearestDistance = 56.0 * 56.0;
    for (final entry in layout.positions.entries) {
      final distance = (entry.value - event.localPosition).distanceSquared;
      if (distance <= nearestDistance) {
        nearestDistance = distance;
        nearest = entry.key;
      }
    }
    if (nearest != null) onNodeTap(nearest);
  }

  @override
  Widget build(BuildContext context) {
    final size = layout.stageSize;
    final cx = size.width / 2;
    final focusY = layout.rowY[0] ?? size.height / 2;

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerUp: _handleTap,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.5, 0.45),
                  radius: 0.65,
                  colors: [AhlColors.ring, Colors.transparent],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
          // blobs
          _Blob(
            motion: motion,
            left: -60,
            top: size.height * 0.10,
            size: 220,
            color: AhlColors.avatarPastelD,
          ),
          _Blob(
            motion: motion,
            left: size.width - 60 - 200,
            top: size.height * 0.84 - 200,
            size: 200,
            color: AhlColors.avatarPastelB,
            reverse: true,
          ),
          _Blob(
            motion: motion,
            left: size.width * 0.20 - 80,
            top: -30 + size.height * 0.0,
            size: 160,
            color: AhlColors.avatarPastelC,
          ),
          // rings
          Positioned(
            left: cx - 75,
            top: focusY - 75,
            child: SizedBox(
              width: 150,
              height: 150,
              child: AnimatedBuilder(
                animation: sonar,
                builder: (_, child) {
                  final s = 0.7 + sonar.value;
                  final o = 1.0 - sonar.value;
                  return Transform.scale(
                    scale: s,
                    child: Opacity(opacity: o, child: child),
                  );
                },
                child: CustomPaint(
                  size: const Size(150, 150),
                  painter: _RingPainter(color: AhlColors.ring, stroke: 1.5),
                ),
              ),
            ),
          ),
          Positioned(
            left: cx - 145,
            top: focusY - 145,
            child: AnimatedBuilder(
              animation: motion,
              builder: (_, child) =>
                  Transform.rotate(angle: motion.value * 2 * pi, child: child),
              child: CustomPaint(
                size: const Size(290, 290),
                painter: _RingPainter(color: AhlColors.ring, stroke: 1.5),
              ),
            ),
          ),
          Positioned(
            left: cx - 220,
            top: focusY - 220,
            child: AnimatedBuilder(
              animation: motion,
              builder: (_, child) =>
                  Transform.rotate(angle: -motion.value * 2 * pi, child: child),
              child: CustomPaint(
                size: const Size(440, 440),
                painter: _RingPainter(color: AhlColors.ring, stroke: 1.5),
              ),
            ),
          ),
          // lines behind nodes
          CustomPaint(
            size: size,
            painter: _OrbitLinesPainter(
              orbit: orbit,
              positions: layout.positions,
              focusId: focusId,
              drawProgress: draw.value,
              dashPhase: motion.value,
              pulse: pulse.value,
            ),
          ),
          // nodes
          ...orbit.entries.map(
            (entry) => _OrbitNode(
              entry: entry,
              layout: layout,
              focusId: focusId,
              selfId: selfId,
              orbit: orbit,
              motion: motion,
              pulse: pulse,
              onTap: onNodeTap,
            ),
          ),
          // waves
          if (waveOrigin != null)
            CustomPaint(
              size: size,
              painter: _WavePainter(progress: wave.value, origin: waveOrigin!),
            ),
          // confetti
          if (confettiOrigin != null && confetti.isAnimating)
            CustomPaint(
              size: size,
              painter: _ConfettiPainter(
                progress: confetti.value,
                origin: confettiOrigin!,
              ),
            ),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({
    required this.motion,
    required this.left,
    required this.top,
    required this.size,
    required this.color,
    this.reverse = false,
  });

  final AnimationController motion;
  final double left;
  final double top;
  final double size;
  final Color color;
  final bool reverse;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: motion,
      builder: (_, child) {
        final dir = reverse ? -1.0 : 1.0;
        final dx = sin(motion.value * 2 * pi) * 40 * dir;
        final dy = cos(motion.value * 2 * pi * 0.7) * 50;
        return Positioned(
          left: left + dx,
          top: top + dy,
          child: ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: 42, sigmaY: 42),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.45),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
      child: const SizedBox.shrink(),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.color, required this.stroke});
  final Color color;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = color
      ..strokeCap = StrokeCap.round;
    const dashes = 40;
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    for (var i = 0; i < dashes; i++) {
      final a1 = (2 * pi * i) / dashes;
      final a2 = (2 * pi * (i + 0.6)) / dashes;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        a1,
        a2 - a1,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter _) => false;
}

int _orbitHash(String id) {
  var h = 0;
  for (var i = 0; i < id.length; i++) {
    h = (h * 31 + id.codeUnitAt(i)) & 0x7fffffff;
  }
  return h;
}

class _OrbitNode extends StatelessWidget {
  const _OrbitNode({
    required this.entry,
    required this.layout,
    required this.focusId,
    required this.selfId,
    required this.orbit,
    required this.motion,
    required this.pulse,
    required this.onTap,
  });

  final MapEntry<String, OrbitPerson> entry;
  final OrbitLayoutResult layout;
  final String focusId;
  final String selfId;
  final Map<String, OrbitPerson> orbit;
  final AnimationController motion;
  final AnimationController pulse;
  final ValueSetter<String> onTap;

  @override
  Widget build(BuildContext context) {
    final id = entry.key;
    final person = entry.value;
    final pos = layout.positions[id];
    final isFocus = id == focusId;
    final visible = pos != null;
    final relation = orbitRelation(
      people: orbit,
      id: id,
      focusId: focusId,
      selfId: selfId,
    );
    final cx = layout.stageSize.width / 2;
    final focusY = layout.rowY[0] ?? layout.stageSize.height / 2;
    return AnimatedPositioned(
      key: ValueKey('node-$id'),
      left: visible ? pos.dx - 42 : cx - 42,
      top: visible ? pos.dy - 32 : focusY - 32,
      width: 84,
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutBack,
      child: Opacity(
        opacity: visible ? 1 : 0,
        child: Semantics(
          button: true,
          label: '${person.name}\n$relation',
          onTap: () => onTap(id),
          excludeSemantics: true,
          child: _Node(
            id: id,
            person: person,
            relation: relation,
            isFocus: isFocus,
            index: _orbitHash(id) % 4,
            motion: motion,
            pulse: pulse,
          ),
        ),
      ),
    );
  }
}

class _Node extends StatelessWidget {
  const _Node({
    required this.id,
    required this.person,
    required this.relation,
    required this.isFocus,
    required this.index,
    required this.motion,
    required this.pulse,
  });

  final String id;
  final OrbitPerson person;
  final String relation;
  final bool isFocus;
  final int index;
  final AnimationController motion;
  final AnimationController pulse;

  @override
  Widget build(BuildContext context) {
    final bobPhase = (_orbitHash(id) % 100) / 100;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 64,
          height: 64,
          child: AnimatedBuilder(
            animation: motion,
            builder: (_, _) {
              final dy = sin(2 * pi * motion.value + bobPhase * 2 * pi) * -5;
              return Transform.translate(
                offset: Offset(0, dy),
                child: AnimatedScale(
                  scale: isFocus ? 1.28 : 1.0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  child: _Avatar(
                    person: person,
                    index: index,
                    isFocus: isFocus,
                    pulse: pulse,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          person.name,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AhlColors.ink,
            height: 1.1,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 1),
        Text(
          relation,
          style: TextStyle(fontSize: 10, color: AhlColors.muted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.person,
    required this.index,
    required this.isFocus,
    required this.pulse,
  });

  final OrbitPerson person;
  final int index;
  final bool isFocus;
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    final s = pulse.value;
    return Container(
      width: 64,
      height: 64,
      decoration: isFocus
          ? BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.7,
                colors: [
                  AhlColors.ring.withValues(alpha: 0.14),
                  Colors.transparent,
                ],
                stops: const [0.0, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(
                    ((1.0 - s) * 0x73).round(),
                    192,
                    38,
                    211,
                  ),
                  spreadRadius: 20 * s,
                  blurRadius: 0,
                ),
              ],
            )
          : null,
      child: ClipOval(child: _orbitAvatarFace(person, 64, index)),
    );
  }
}

class _OrbitLinesPainter extends CustomPainter {
  _OrbitLinesPainter({
    required this.orbit,
    required this.positions,
    required this.focusId,
    required this.drawProgress,
    required this.dashPhase,
    required this.pulse,
  });

  final Map<String, OrbitPerson> orbit;
  final Map<String, Offset> positions;
  final String focusId;
  final double drawProgress;
  final double dashPhase;
  final double pulse;

  static const double _r = 32;

  @override
  void paint(Canvas canvas, Size size) {
    var gi = 0;
    final lineProgress = (drawProgress - 0.5).clamp(0.0, 1.0);

    for (final id in positions.keys) {
      final person = orbit[id];
      if (person == null) continue;
      final visibleParents = person.parents
          .where((x) => positions.containsKey(x))
          .toList();
      if (visibleParents.isEmpty) continue;

      final sx =
          visibleParents.map((x) => positions[x]!.dx).reduce((a, b) => a + b) /
          visibleParents.length;
      final first = positions[visibleParents.first]!;
      final sy = first.dy + (visibleParents.length > 1 ? 2 : _r);
      final x2 = positions[id]!.dx;
      final y2 = positions[id]!.dy - _r;
      final my = (sy + y2) / 2;
      final path = Path()
        ..moveTo(sx, sy)
        ..cubicTo(sx, my, x2, my, x2, y2);

      final hot = id == focusId || person.parents.contains(focusId);
      final ui.PathMetric metric = path.computeMetrics().first;
      final length = metric.length;
      final segProgress = (lineProgress - gi * 0.08).clamp(0.0, 1.0);
      final drawPath = metric.extractPath(0, length * segProgress);

      // glow halo
      if (segProgress > 0.55) {
        final glow = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = hot ? 14 : 11
          ..color = hot ? AhlColors.gold.withValues(alpha: 0.2) : AhlColors.glow
          ..strokeCap = StrokeCap.round;
        canvas.drawPath(drawPath, glow);
      }

      // main gradient stroke
      final main = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = hot ? 4 : 3
        ..strokeCap = StrokeCap.round
        ..shader =
            (hot ? AhlColors.orbitGoldGradient : AhlColors.orbitPrimaryGradient)
                .createShader(Rect.fromPoints(Offset(sx, sy), Offset(x2, y2)));
      canvas.drawPath(drawPath, main);

      // white dashed flowing overlay
      final fl = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = hot ? 2.2 : 1.6
        ..color = hot ? const Color(0xFFF6E3AE) : Colors.white
        ..strokeCap = StrokeCap.round;
      final dashMetric = path.computeMetrics().first;
      _drawDashed(canvas, dashMetric, dashPhase, fl, 0.85);

      // comets
      final cometPaint = Paint()
        ..color = hot ? AhlColors.gold : AhlColors.primaryGradientEnd;
      for (var c = 0; c < 2; c++) {
        final offset =
            (dashPhase * length * (hot ? 2.2 : 1.1) + c * length / 2) % length;
        final tangent = dashMetric.getTangentForOffset(offset.clamp(0, length));
        if (tangent == null) continue;
        final halo = Paint()
          ..color = (hot ? AhlColors.gold : AhlColors.primaryGradientEnd)
              .withValues(alpha: 0.35);
        canvas.drawCircle(tangent.position, 7, halo);
        canvas.drawCircle(tangent.position, 3, cometPaint);
      }

      // child endpoint dot
      final endPaint = Paint()
        ..color = hot ? AhlColors.gold : AhlColors.primaryGradientEnd;
      canvas.drawCircle(Offset(x2, y2), 4, endPaint);

      gi++;
    }

    // partner lines
    for (final id in positions.keys) {
      final person = orbit[id];
      final spouse = person?.spouse;
      if (spouse == null || !positions.containsKey(spouse)) continue;
      if (id.compareTo(spouse) >= 0) continue;
      final a = positions[id]!;
      final b = positions[spouse]!;
      final left = a.dx < b.dx ? a : b;
      final right = a.dx < b.dx ? b : a;
      final y = left.dy;
      final line = Path()
        ..moveTo(left.dx + _r, y)
        ..lineTo(right.dx - _r, y);
      final metric = line.computeMetrics().first;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = AhlColors.gold
        ..strokeCap = StrokeCap.round;
      _drawDashed(canvas, metric, dashPhase * 2, paint, 1.0);

      final mid = Offset((left.dx + right.dx) / 2, y + 4);
      final tp = TextPainter(
        text: const TextSpan(
          text: '\u2764',
          style: TextStyle(fontSize: 16, color: AhlColors.gold),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final scale = 1.0 + 0.4 * ((sin(pulse * 2 * pi) + 1) / 2);
      canvas.save();
      canvas.translate(
        mid.dx - tp.width / 2 * scale,
        mid.dy - tp.height / 2 * scale,
      );
      canvas.scale(scale);
      tp.paint(canvas, Offset.zero);
      canvas.restore();
    }
    canvas.restore();
  }

  void _drawDashed(
    Canvas canvas,
    ui.PathMetric metric,
    double phase,
    Paint paint,
    double opacity,
  ) {
    final length = metric.length;
    const dash = 5.0;
    const period = dash + 11.0;
    var start = (phase * period) % period;
    if (start < 0) start += period;
    while (start < length) {
      final end = (start + dash).clamp(0, length);
      if (end > start) {
        final seg = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = paint.strokeWidth
          ..color = paint.color.withValues(alpha: opacity)
          ..strokeCap = paint.strokeCap;
        canvas.drawPath(
          metric.extractPath(start.toDouble(), end.toDouble()),
          seg,
        );
      }
      start += period;
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitLinesPainter old) =>
      old.drawProgress != drawProgress ||
      old.dashPhase != dashPhase ||
      old.pulse != pulse ||
      old.focusId != focusId;
}

class _WavePainter extends CustomPainter {
  _WavePainter({required this.progress, required this.origin});
  final double progress;
  final Offset origin;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    for (var i = 0; i < 2; i++) {
      final offset = i * 0.25;
      final p = ((progress - offset) / 0.75).clamp(0.0, 1.0);
      if (p <= 0 || p >= 1) continue;
      final scale = 0.4 + 8.6 * p;
      final alpha = 0.9 * (1 - p);
      final p2 = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AhlColors.primary.withValues(alpha: alpha);
      canvas.drawCircle(origin, 30 * scale, p2);
    }
  }

  @override
  bool shouldRepaint(covariant _WavePainter old) =>
      old.progress != progress || old.origin != origin;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress, required this.origin});
  final double progress;
  final Offset origin;

  static final List<Color> _colors = [
    AhlColors.avatarPastelA,
    AhlColors.avatarPastelB,
    AhlColors.avatarPastelC,
    AhlColors.avatarPastelD,
    AhlColors.primary,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final random = Random(1);
    for (var i = 0; i < 18; i++) {
      final a = (i / 18) * 2 * pi + random.nextDouble() * 0.4;
      final d = 50 + random.nextDouble() * 55;
      final dx = cos(a) * d * progress;
      final dy = sin(a) * d * progress;
      final r = random.nextDouble() * 540 - 270;
      final paint = Paint()
        ..color = _colors[i % _colors.length].withValues(alpha: 1 - progress)
        ..style = PaintingStyle.fill;
      canvas.save();
      canvas.translate(origin.dx + dx, origin.dy + dy);
      canvas.rotate(r);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: 8, height: 8),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) =>
      old.progress != progress || old.origin != origin;
}
