import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class FileUploadBoxWidget extends StatelessWidget {
  final String? selectedFileName;
  final String fileType;
  final VoidCallback onClear;
  final VoidCallback onPick;

  const FileUploadBoxWidget({
    super.key,
    required this.selectedFileName,
    required this.fileType,
    required this.onClear,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = selectedFileName != null;

    return InkWell(
      onTap: hasFile ? null : onPick,
      child: Container(
        padding: AppSpacing.paddingLg,
        decoration: BoxDecoration(
          border: Border.all(
            color: hasFile ? AppColors.success : Colors.grey.shade300,
            width: hasFile ? 2 : 1,
          ),
          borderRadius: AppSpacing.borderRadiusMd,
          color: hasFile ? AppColors.success.withOpacity(0.05) : null,
        ),
        child: Column(
          children: [
            Icon(
              hasFile
                  ? Icons.check_circle
                  : (fileType == 'video'
                        ? Icons.video_library_outlined
                        : Icons.description_outlined),
              size: 40,
              color: hasFile ? AppColors.success : Colors.grey.shade400,
            ),
            AppSpacing.gapV8,
            Text(
              hasFile
                  ? selectedFileName!
                  : (fileType == 'video'
                        ? 'Chọn file video'
                        : 'Chọn file tài liệu'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: hasFile ? AppColors.success : Colors.grey.shade600,
                fontWeight: hasFile ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            if (hasFile) ...[
              AppSpacing.gapV8,
              TextButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.close, size: 16),
                label: const Text('Xóa'),
                style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class VideoSourceToggle extends StatelessWidget {
  final String currentSource;
  final ValueChanged<String> onChanged;

  const VideoSourceToggle({
    super.key,
    required this.currentSource,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ToggleOption(
          icon: Icons.link,
          label: 'Nhập URL',
          isSelected: currentSource == 'url',
          isLeft: true,
          onTap: () => onChanged('url'),
        ),
        _ToggleOption(
          icon: Icons.upload_file,
          label: 'Upload từ máy',
          isSelected: currentSource == 'upload',
          isLeft: false,
          onTap: () => onChanged('upload'),
        ),
      ],
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isLeft;
  final VoidCallback onTap;

  const _ToggleOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isLeft,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.grey[200],
            borderRadius: BorderRadius.horizontal(
              left: isLeft ? const Radius.circular(8) : Radius.zero,
              right: isLeft ? Radius.zero : const Radius.circular(8),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
