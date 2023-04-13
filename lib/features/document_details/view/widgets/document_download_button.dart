import 'dart:io';

import 'package:flutter/material.dart';
import 'package:paperless_api/paperless_api.dart';
import 'package:paperless_mobile/extensions/flutter_extensions.dart';
import 'package:paperless_mobile/features/document_details/cubit/document_details_cubit.dart';
import 'package:paperless_mobile/features/document_details/view/dialogs/select_file_type_dialog.dart';
import 'package:paperless_mobile/features/settings/global_app_settings.dart';
import 'package:paperless_mobile/features/settings/cubit/application_settings_cubit.dart';
import 'package:paperless_mobile/generated/l10n/app_localizations.dart';

import 'package:paperless_mobile/helpers/message_helpers.dart';
import 'package:paperless_mobile/helpers/permission_helpers.dart';
import 'package:paperless_mobile/constants.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DocumentDownloadButton extends StatefulWidget {
  final DocumentModel? document;
  final bool enabled;
  final Future<DocumentMetaData> metaData;
  const DocumentDownloadButton({
    super.key,
    required this.document,
    this.enabled = true,
    required this.metaData,
  });

  @override
  State<DocumentDownloadButton> createState() => _DocumentDownloadButtonState();
}

class _DocumentDownloadButtonState extends State<DocumentDownloadButton> {
  bool _isDownloadPending = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: S.of(context)!.downloadDocumentTooltip,
      icon: _isDownloadPending
          ? const SizedBox(
              child: CircularProgressIndicator(),
              height: 16,
              width: 16,
            )
          : const Icon(Icons.download),
      onPressed: widget.document != null && widget.enabled
          ? () => _onDownload(widget.document!)
          : null,
    ).paddedOnly(right: 4);
  }

  Future<void> _onDownload(DocumentModel document) async {
    try {
      final downloadOriginal = await showDialog<bool>(
        context: context,
        builder: (context) => const SelectFileTypeDialog(),
      );
      if (downloadOriginal == null) {
        // Download was cancelled
        return;
      }
      if (Platform.isAndroid && androidInfo!.version.sdkInt! <= 29) {
        final isGranted = await askForPermission(Permission.storage);
        if (!isGranted) {
          return;
          //TODO: Tell user to grant permissions
        }
      }
      setState(() => _isDownloadPending = true);
      await context.read<DocumentDetailsCubit>().downloadDocument(
            downloadOriginal: downloadOriginal,
            locale: context.read<GlobalAppSettings>().preferredLocaleSubtag,
          );
      // showSnackBar(context, S.of(context)!.documentSuccessfullyDownloaded);
    } on PaperlessServerException catch (error, stackTrace) {
      showErrorMessage(context, error, stackTrace);
    } catch (error) {
      showGenericError(context, error);
    } finally {
      if (mounted) {
        setState(() => _isDownloadPending = false);
      }
    }
  }
}
