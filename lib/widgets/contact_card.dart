import 'package:flutter/material.dart';
import '../models.dart';
import '../utils/color_utils.dart';

/// Widget for displaying a contact card
class ContactCard extends StatelessWidget {
  final StoredContact contact;
  final double height;
  final double overlayHeight;
  final bool isCurrentPage;
  final bool isMatch;
  final bool isHudVisible;
  final bool showNameFlash;
  final String?
      activeFlashType; // 'base', 'overlay', 'cross1', 'cross2', or null
  final AnimationController heartAnimationController;
  final AnimationController flashAnimationController;
  final bool showSelfContactFlash;
  final AnimationController? selfContactFlashController;
  final VoidCallback onTap;
  final ValueChanged<double> onVerticalDragUpdate;
  final VoidCallback? onEdit;
  final VoidCallback onToggleFavorite;
  final VoidCallback onReorder;
  final VoidCallback onDelete;
  final bool isOrderingActive;

  const ContactCard({
    super.key,
    required this.contact,
    required this.height,
    required this.overlayHeight,
    required this.isCurrentPage,
    required this.isMatch,
    required this.isHudVisible,
    required this.showNameFlash,
    this.activeFlashType,
    required this.heartAnimationController,
    required this.flashAnimationController,
    this.showSelfContactFlash = false,
    this.selfContactFlashController,
    required this.onTap,
    required this.onVerticalDragUpdate,
    this.onEdit,
    required this.onToggleFavorite,
    required this.onReorder,
    required this.onDelete,
    this.isOrderingActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onVerticalDragUpdate: (details) {
        onVerticalDragUpdate(details.delta.dy);
      },
      child: SizedBox(
        height: height,
        child: Card(
          margin: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          child: Stack(
            children: [
              // Base color area with flash highlight
              Positioned.fill(
                child: _buildBaseColorArea(),
              ),
              // Overlay color area with flash highlight
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: height * overlayHeight,
                child: _buildOverlayColorArea(),
              ),
              // Content (name and HUD)
              SizedBox.expand(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AnimationController get _activeFlashController =>
      showSelfContactFlash && selfContactFlashController != null
          ? selfContactFlashController!
          : flashAnimationController;

  bool get _shouldFlashBase =>
      isCurrentPage && (activeFlashType == 'base' || showSelfContactFlash);

  bool get _shouldFlashOverlay =>
      isCurrentPage && (activeFlashType == 'overlay' || showSelfContactFlash);

  Widget _buildBaseColorArea() {
    return AnimatedBuilder(
      animation: _activeFlashController,
      builder: (context, child) {
        final flashOpacity =
            _shouldFlashBase ? _activeFlashController.value * 0.6 : 0.0;
        return Stack(
          children: [
            Container(
              color: ColorUtils.colorFromValue(contact.color),
            ),
            if (flashOpacity > 0)
              Container(
                color: Colors.white.withValues(alpha: flashOpacity),
              ),
          ],
        );
      },
    );
  }

  Widget _buildOverlayColorArea() {
    return AnimatedBuilder(
      animation: _activeFlashController,
      builder: (context, child) {
        final flashOpacity =
            _shouldFlashOverlay ? _activeFlashController.value * 0.6 : 0.0;
        return Stack(
          children: [
            Container(
              color: ColorUtils.overlayColorFromValue(contact.color),
            ),
            if (flashOpacity > 0)
              Container(
                color: Colors.white.withValues(alpha: flashOpacity),
              ),
          ],
        );
      },
    );
  }

  Widget _buildContent() {
    final shouldShowContent = isHudVisible || (isCurrentPage && showNameFlash);

    if (!shouldShowContent) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: _buildContactName(),
        ),
        if (isHudVisible) ...[
          const SizedBox(height: 16),
          _buildHudButtons(),
        ],
      ],
    );
  }

  Widget _buildContactName() {
    return AnimatedBuilder(
      animation: isCurrentPage && isMatch
          ? heartAnimationController
          : const AlwaysStoppedAnimation(0.0),
      builder: (context, child) {
        final shouldFlash = isCurrentPage && isMatch && showNameFlash;
        final flashOpacity =
            shouldFlash ? (heartAnimationController.value * 0.3 + 0.7) : 1.0;
        return Opacity(
          opacity: flashOpacity,
          child: GestureDetector(
            onTap: isHudVisible ? onEdit : null,
            child: Text(
              contact.name,
              style: const TextStyle(
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 8,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      },
    );
  }

  Widget _buildHudButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildFavoriteButton(),
        const SizedBox(width: 16),
        _buildReorderButton(),
        const SizedBox(width: 16),
        _buildDeleteButton(),
      ],
    );
  }

  Widget _buildFavoriteButton() {
    if (isCurrentPage && isMatch) {
      return AnimatedBuilder(
        animation: heartAnimationController,
        builder: (context, child) {
          final scale = 1.0 + (heartAnimationController.value * 0.2);
          return Transform.scale(
            scale: scale,
            child: IconButton(
              icon: Icon(
                contact.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Colors.white,
                size: 32,
              ),
              onPressed: onToggleFavorite,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
            ),
          );
        },
      );
    }

    return IconButton(
      icon: Icon(
        contact.isFavorite ? Icons.favorite : Icons.favorite_border,
        color: Colors.white,
        size: 32,
      ),
      onPressed: onToggleFavorite,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildReorderButton() {
    return IconButton(
      icon: isOrderingActive
          ? Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2.0,
                ),
              ),
              padding: const EdgeInsets.all(4.0),
              child: const Icon(
                Icons.lock,
                color: Colors.white,
                size: 24,
              ),
            )
          : const Icon(
              Icons.bar_chart,
              color: Colors.white,
              size: 32,
            ),
      onPressed: onReorder,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildDeleteButton() {
    return IconButton(
      icon: const Icon(
        Icons.delete_outline,
        color: Colors.white,
        size: 32,
      ),
      onPressed: onDelete,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      visualDensity: VisualDensity.compact,
    );
  }
}
