import 'package:flutter/material.dart';
import 'package:ephenotes/core/constants/ui_strings.dart';
import 'package:ephenotes/core/error/app_error.dart';
import 'package:ephenotes/presentation/bloc/notes_state.dart';
import 'package:ephenotes/core/utils/accessibility_helper.dart';

/// Widget for displaying comprehensive error information with recovery actions.
///
/// Shows user-friendly error messages, recovery options, and maintains
/// accessibility standards for error states.
class ErrorDisplayWidget extends StatelessWidget {
  /// The error state to display.
  final NotesError errorState;

  /// Callback when a recovery action is selected.
  final void Function(ErrorRecoveryAction action)? onRecoveryAction;

  /// Whether to show detailed error information (for debugging).
  final bool showDetails;

  const ErrorDisplayWidget({
    super.key,
    required this.errorState,
    this.onRecoveryAction,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Semantics(
      label: AccessibilityHelper.getErrorSemanticLabel(errorState.message),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error icon
              Icon(
                _getErrorIcon(errorState.type),
                size: 64,
                color: _getErrorColor(errorState.type, isDark),
              ),
              const SizedBox(height: 16),

              // Error title
              Text(
                _getErrorTitle(errorState.type),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: _getErrorColor(errorState.type, isDark),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Error message
              Text(
                errorState.message,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),

              // Recovery actions
              if (errorState.hasRecoveryActions) ...[
                const SizedBox(height: 24),
                _buildRecoveryActions(context, errorState.recoveryActions),
              ],

              // Details section (for debugging)
              if (showDetails && errorState.error != null) ...[
                const SizedBox(height: 24),
                _buildDetailsSection(context, errorState),
              ],

              // Help section
              const SizedBox(height: 24),
              _buildHelpSection(context, errorState.type),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the recovery actions section.
  Widget _buildRecoveryActions(
      BuildContext context, List<ErrorRecoveryAction> actions) {
    return Column(
      children: [
        Text(
          UiStrings.whatWouldYouLikeToDo,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 16),
        ...actions.map((action) => _buildRecoveryActionButton(context, action)),
      ],
    );
  }

  /// Builds a single recovery action button.
  Widget _buildRecoveryActionButton(
      BuildContext context, ErrorRecoveryAction action) {
    final isPrimary = action.isPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: SizedBox(
        width: double.infinity,
        child: Semantics(
          label: '${action.label}: ${action.description}',
          button: true,
          child: isPrimary
              ? ElevatedButton(
                  onPressed: () => _handleRecoveryAction(action),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(action.label),
                )
              : OutlinedButton(
                  onPressed: () => _handleRecoveryAction(action),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(action.label),
                ),
        ),
      ),
    );
  }

  /// Builds the details section for debugging.
  Widget _buildDetailsSection(BuildContext context, NotesError errorState) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ExpansionTile(
      title: Text(
        UiStrings.technicalDetails,
        style: theme.textTheme.titleSmall,
      ),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                UiStrings.errorType(errorState.type.name),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                UiStrings.details(errorState.error.toString()),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the help section with additional guidance.
  Widget _buildHelpSection(BuildContext context, NotesErrorType errorType) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final helpText = _getHelpText(errorType);
    if (helpText.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isDark ? Colors.blue[900]?.withValues(alpha: 0.3) : Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.blue[700]! : Colors.blue[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: isDark ? Colors.blue[300] : Colors.blue[700],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              helpText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.blue[300] : Colors.blue[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Handles recovery action selection.
  void _handleRecoveryAction(ErrorRecoveryAction action) {
    onRecoveryAction?.call(action);
    action.action();
  }

  /// Gets the appropriate icon for the error type.
  IconData _getErrorIcon(NotesErrorType type) {
    switch (type) {
      case NotesErrorType.storage:
        return Icons.storage;
      case NotesErrorType.validation:
        return Icons.warning;
      case NotesErrorType.network:
        return Icons.wifi_off;
      case NotesErrorType.unknown:
        return Icons.error_outline;
    }
  }

  /// Gets the appropriate color for the error type.
  Color _getErrorColor(NotesErrorType type, bool isDark) {
    switch (type) {
      case NotesErrorType.storage:
        return isDark ? Colors.orange[300]! : Colors.orange[700]!;
      case NotesErrorType.validation:
        return isDark ? Colors.amber[300]! : Colors.amber[700]!;
      case NotesErrorType.network:
        return isDark ? Colors.blue[300]! : Colors.blue[700]!;
      case NotesErrorType.unknown:
        return isDark ? Colors.red[300]! : Colors.red[700]!;
    }
  }

  /// Gets the appropriate title for the error type.
  String _getErrorTitle(NotesErrorType type) {
    switch (type) {
      case NotesErrorType.storage:
        return UiStrings.storageIssueTitle;
      case NotesErrorType.validation:
        return UiStrings.inputErrorTitle;
      case NotesErrorType.network:
        return UiStrings.connectionProblemTitle;
      case NotesErrorType.unknown:
        return UiStrings.somethingWentWrongTitle;
    }
  }

  /// Gets helpful text for the error type.
  String _getHelpText(NotesErrorType type) {
    switch (type) {
      case NotesErrorType.storage:
        return UiStrings.storageHelpText;
      case NotesErrorType.validation:
        return UiStrings.validationHelpText;
      case NotesErrorType.network:
        return UiStrings.networkHelpText;
      case NotesErrorType.unknown:
        return UiStrings.unknownErrorHelpText;
    }
  }
}
