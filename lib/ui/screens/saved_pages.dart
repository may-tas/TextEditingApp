import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/canvas_cubit.dart';
import '../../utils/custom_snackbar.dart';
import '../../constants/color_constants.dart';

class SavedPagesScreen extends StatefulWidget {
  const SavedPagesScreen({super.key});

  @override
  State<SavedPagesScreen> createState() => _SavedPagesScreenState();
}

class _SavedPagesScreenState extends State<SavedPagesScreen> {
  List<String> savedPages = [];
  List<Map<String, dynamic>> pagesPreviews = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedPages();
  }

  Future<void> _loadSavedPages() async {
    setState(() {
      isLoading = true;
    });

    try {
      final canvasCubit = context.read<CanvasCubit>();
      savedPages = await canvasCubit.getSavedPages();

      // Load previews for each page
      pagesPreviews = [];
      for (String pageName in savedPages) {
        final preview = await canvasCubit.getPagePreview(pageName);
        if (preview != null) {
          pagesPreviews.add(preview);
        } else {
          // If preview fails, create basic info
          pagesPreviews.add({
            'name': pageName,
            'textCount': 0,
            'backgroundColor': ColorConstants.dialogTextBlack,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
            'lastModified': DateTime.now(),
          });
        }
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        CustomSnackbar.showError('Error deleting page');
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.gray50,
      appBar: AppBar(
        title: const Text(
          'Saved Pages',
          style: TextStyle(
            color: ColorConstants.dialogTextBlack,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: ColorConstants.dialogWhite,
        foregroundColor: ColorConstants.dialogTextBlack,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ColorConstants.dialogTextBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: ColorConstants.gray600),
            onPressed: _loadSavedPages,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: ColorConstants.gray600,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading saved pages...',
                    style: TextStyle(
                      color: ColorConstants.gray600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : savedPages.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 80,
                        color: ColorConstants.gray400,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No saved pages yet',
                        style: TextStyle(
                          fontSize: 20,
                          color: ColorConstants.gray600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Create and save your first page!',
                        style: TextStyle(
                          fontSize: 16,
                          color: ColorConstants.gray500,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadSavedPages,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: pagesPreviews.length,
                    itemBuilder: (context, index) {
                      final preview = pagesPreviews[index];
                      final pageName = preview['name'] as String;
                      final textCount = preview['textCount'] as int? ?? 0;
                      final backgroundColor =
                          preview['backgroundColor'] as Color? ?? ColorConstants.uiGrayMedium;
                      final lastModified = preview['lastModified'] as DateTime;
                      final label = (preview['label'] as String?) ?? '';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _loadPage(pageName),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Page preview/thumbnail
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: backgroundColor,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: ColorConstants.gray300,
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: label.isNotEmpty
                                        ? Text(
                                            label,
                                            style: const TextStyle(
                                              color: ColorConstants.dialogWhite,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                            textAlign: TextAlign.center,
                                          )
                                        : Icon(
                                            Icons.description,
                                            color:
                                                ColorConstants.dialogWhite.withOpacity(0.8),
                                            size: 28,
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Page info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pageName,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: ColorConstants.dialogTextBlack87,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '$textCount text item${textCount != 1 ? 's' : ''}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: ColorConstants.gray600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Modified ${_formatDateTime(lastModified)}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: ColorConstants.gray500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Action buttons
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.open_in_new,
                                        color: ColorConstants.dialogButtonBlue,
                                        size: 20,
                                      ),
                                      onPressed: () => _loadPage(pageName),
                                      tooltip: 'Open',
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: ColorConstants.dialogRed,
                                        size: 20,
                                      ),
                                      onPressed: () =>
                                          _showDeleteConfirmation(pageName),
                                      tooltip: 'Delete',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  void _loadPage(String pageName) async {
    try {
      await context.read<CanvasCubit>().loadPage(pageName);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError('Error deleting page');
      }
    }
  }

  void _showDeleteConfirmation(String pageName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          'Delete Page',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 16,
              color: ColorConstants.dialogTextBlack87,
            ),
            children: [
              const TextSpan(text: 'Are you sure you want to delete '),
              TextSpan(
                text: '"$pageName"',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: '? This action cannot be undone.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorConstants.dialogRed,
              foregroundColor: ColorConstants.dialogWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              await _deletePage(pageName);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePage(String pageName) async {
    try {
      await context.read<CanvasCubit>().deletePage(pageName);
      await _loadSavedPages(); // Refresh the list

      if (mounted) {
        CustomSnackbar.showInfo('Page "$pageName" deleted successfully');
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError('Error deleting page');
      }
    }
  }
}
