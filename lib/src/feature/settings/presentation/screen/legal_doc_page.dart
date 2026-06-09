import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/config/entity/legal_doc.dart';
import 'package:klozy/src/domain/config/public_config_repository.dart';

@RoutePage()
class LegalDocPage extends StatefulWidget {
  final String docKey;

  const LegalDocPage({@PathParam('key') required this.docKey, super.key});

  @override
  State<LegalDocPage> createState() => _LegalDocPageState();
}

class _LegalDocPageState extends State<LegalDocPage> {
  late final Future<LegalDocContent> _future = locator<PublicConfigRepository>()
      .getLegalDoc(widget.docKey);

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
      body: FutureBuilder<LegalDocContent>(
        future: _future,
        builder:
            (BuildContext context, AsyncSnapshot<LegalDocContent> snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const DSLoader();
              }
              final doc = snapshot.data;
              if (doc == null || doc.body.isEmpty) {
                return Center(
                  child: Text(
                    context.l10N.settings_doc_unavailable,
                    style: const TextStyle(
                      fontFamily: dsFontFamily,
                      fontSize: DSFontSize.bodyMedium,
                      color: DSColor.onSurface45,
                    ),
                  ),
                );
              }
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: <Widget>[
                  if (doc.title.isNotEmpty) ...<Widget>[
                    Text(
                      doc.title,
                      style: const TextStyle(
                        fontFamily: dsFontFamily,
                        fontSize: 22,
                        fontWeight: DSFontWeight.bold,
                        color: DSColor.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    doc.body,
                    style: const TextStyle(
                      fontFamily: dsFontFamily,
                      fontSize: DSFontSize.bodyMedium,
                      height: 1.6,
                      color: DSColor.onSurface75,
                    ),
                  ),
                ],
              );
            },
      ),
    );
  }
}
