// lib/screens/task/add_edit_task_screen.dart
// Add or edit a task — form with full validation

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/date_utils.dart';
import '../../models/task_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/common/error_snackbar.dart';

class AddEditTaskScreen extends StatefulWidget {
  final TaskModel? existingTask;

  const AddEditTaskScreen({super.key, this.existingTask});

  bool get isEditing => existingTask != null;

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String _selectedCategory = 'Personal';
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final task = widget.existingTask;
    if (task != null) {
      _titleCtrl.text = task.title;
      _descCtrl.text = task.description;
      _selectedCategory = task.category;
      if (task.dueDate != null) {
        _dueDate = task.dueDate;
        _dueTime = TimeOfDay.fromDateTime(task.dueDate!);
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  DateTime? get _combinedDueDate {
    if (_dueDate == null) return null;
    final t = _dueTime ?? const TimeOfDay(hour: 9, minute: 0);
    return DateTime(
      _dueDate!.year,
      _dueDate!.month,
      _dueDate!.day,
      t.hour,
      t.minute,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final authProvider = context.read<AuthProvider>();
    final taskProvider = context.read<TaskProvider>();
    final userId = authProvider.user?.uid ?? '';

    final task = widget.isEditing
        ? widget.existingTask!.copyWith(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      category: _selectedCategory,
      dueDate: _combinedDueDate,
      clearDueDate: _combinedDueDate == null,
    )
        : TaskModel(
      id: const Uuid().v4(),
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      category: _selectedCategory,
      dueDate: _combinedDueDate,
      createdAt: DateTime.now(),
      userId: userId,
    );

    final success = widget.isEditing
        ? await taskProvider.updateTask(task)
        : await taskProvider.addTask(task);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.of(context).pop();
    } else {
      showErrorSnackbar(context, 'Failed to save task. Please try again.');
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: AppColors.accent,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: AppColors.accent,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dueTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBg : AppColors.lightBg;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Task' : 'New Task'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.accent),
              )
                  : Text(
                'Save',
                style: AppTextStyles.button(isDark)
                    .copyWith(color: AppColors.accent),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          children: [
            // ── Title ──────────────────────────────────────
            TextFormField(
              controller: _titleCtrl,
              autofocus: !widget.isEditing,
              maxLength: 100,
              style: AppTextStyles.bodyLarge(isDark),
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Task title *',
                counterText: '',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Title is required';
                }
                if (v.trim().length < 2) {
                  return 'Title must be at least 2 characters';
                }
                return null;
              },
            ),

            const SizedBox(height: AppConstants.spacingM),

            // ── Description ────────────────────────────────
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              maxLength: 300,
              style: AppTextStyles.bodyLarge(isDark),
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: AppConstants.spacingM),

            // ── Category ───────────────────────────────────
            _buildLabel('Category', isDark),
            const SizedBox(height: 8),
            _buildCategoryDropdown(isDark),

            const SizedBox(height: AppConstants.spacingM),

            // ── Due Date ───────────────────────────────────
            _buildLabel('Due date', isDark),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _PickerTile(
                    icon: Icons.calendar_today_rounded,
                    label: _dueDate != null
                        ? AppDateUtils.formatDate(_dueDate!)
                        : 'Select date',
                    isDark: isDark,
                    onTap: _pickDate,
                    hasValue: _dueDate != null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PickerTile(
                    icon: Icons.access_time_rounded,
                    label: _dueTime != null
                        ? _dueTime!.format(context)
                        : 'Select time',
                    isDark: isDark,
                    onTap: _dueDate != null ? _pickTime : null,
                    hasValue: _dueTime != null,
                  ),
                ),
              ],
            ),
            if (_dueDate != null) ...[
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => setState(() {
                  _dueDate = null;
                  _dueTime = null;
                }),
                child: Text(
                  'Clear date',
                  style: AppTextStyles.labelSmall(isDark)
                      .copyWith(color: AppColors.error),
                ),
              ),
            ],

            const SizedBox(height: AppConstants.spacingXL),

            // ── Save button ───────────────────────────────
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  disabledBackgroundColor:
                  AppColors.accent.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        AppConstants.radiusMedium),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2)
                    : Text(
                  widget.isEditing ? 'Save Changes' : 'Create Task',
                  style: AppTextStyles.button(false)
                      .copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Text(text, style: AppTextStyles.labelMedium(isDark));
  }

  Widget _buildCategoryDropdown(bool isDark) {
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          style: AppTextStyles.bodyLarge(isDark),
          dropdownColor: cardColor,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
          items: AppConstants.taskCategories.map((cat) {
            return DropdownMenuItem(
              value: cat,
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _categoryColor(cat),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(cat),
                ],
              ),
            );
          }).toList(),
          onChanged: (v) {
            if (v != null) setState(() => _selectedCategory = v);
          },
        ),
      ),
    );
  }

  Color _categoryColor(String cat) {
    final idx = AppConstants.taskCategories.indexOf(cat);
    if (idx == -1) return AppColors.accent;
    return AppColors.categoryColors[idx % AppColors.categoryColors.length];
  }
}

// ── Picker Tile ───────────────────────────────────────────────────

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback? onTap;
  final bool hasValue;

  const _PickerTile({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
    this.hasValue = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final disabled = onTap == null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: disabled
              ? (isDark ? AppColors.darkBg : AppColors.lightBg)
              : cardColor,
          borderRadius:
          BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(
            color: hasValue ? AppColors.accent : border,
            width: hasValue ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: disabled
                  ? (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)
                  : (hasValue ? AppColors.accent : AppColors.lightTextSecondary),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.labelMedium(isDark).copyWith(
                  color: disabled
                      ? (isDark
                      ? AppColors.darkTextMuted
                      : AppColors.lightTextMuted)
                      : (hasValue ? AppColors.accent : null),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
