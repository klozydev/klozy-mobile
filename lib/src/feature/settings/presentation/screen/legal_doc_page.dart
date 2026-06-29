import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/core/network/base_url/base_url.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/di/injection.dart';

/// In-app browser for an admin-edited legal document. The actual page
/// (title, copy, last-updated stamp) is served by the API as a rendered
/// HTML page at `v1/legal/{key}.html`, so edits in the admin take effect
/// without a mobile release.
@RoutePage()
class LegalDocPage extends StatefulWidget {
  final String docKey;

  const LegalDocPage({@PathParam('key') required this.docKey, super.key});

  @override
  State<LegalDocPage> createState() => _LegalDocPageState();
}

class _LegalDocPageState extends State<LegalDocPage> {
  bool _loading = true;
  bool _failed = false;

  late final WebUri _uri = WebUri(
    '${locator<BaseUrl>().baseUrl}v1/legal/${widget.docKey}.html',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColor.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 22),
          onPressed: () => context.router.maybePop(),
        ),
      ),
      body: Stack(
        children: <Widget>[
          if (!_failed)
            InAppWebView(
              initialUrlRequest: URLRequest(url: _uri),
              initialSettings: InAppWebViewSettings(
                transparentBackground: true,
                disableContextMenu: true,
                supportZoom: false,
              ),
              onLoadStop: (_, _) => setState(() => _loading = false),
              onReceivedError: (_, _, _) =>
                  setState(() => _failed = true),
              onReceivedHttpError: (_, _, _) =>
                  setState(() => _failed = true),
            ),
          if (_loading && !_failed) const DSLoader(),
          if (_failed)
            Center(
              child: Text(
                context.l10N.settings_doc_unavailable,
                style: const TextStyle(
                  fontFamily: dsFontFamily,
                  fontSize: DSFontSize.bodyMedium,
                  color: DSColor.onSurface45,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
