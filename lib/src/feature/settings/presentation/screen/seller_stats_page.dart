import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/me/entity/seller_stats.dart';
import 'package:klozy/src/domain/me/me_repository.dart';

@RoutePage()
class SellerStatsPage extends StatefulWidget {
  const SellerStatsPage({super.key});

  @override
  State<SellerStatsPage> createState() => _SellerStatsPageState();
}

class _SellerStatsPageState extends State<SellerStatsPage> {
  late final Future<SellerStats> _future = locator<MeRepository>()
      .getSellerStats();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColor.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 22),
          onPressed: () => context.router.maybePop(),
        ),
        title: Text(context.l10N.settings_seller_stats),
      ),
      body: FutureBuilder<SellerStats>(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<SellerStats> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const DSLoader();
          }
          final entries = snapshot.data?.entries ?? const <SellerStat>[];
          if (entries.isEmpty) {
            return Center(
              child: Text(
                context.l10N.settings_no_stats,
                style: const TextStyle(
                  fontFamily: dsFontFamily,
                  fontSize: DSFontSize.bodyMedium,
                  color: DSColor.onSurface45,
                ),
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
            ),
            itemCount: entries.length,
            itemBuilder: (BuildContext context, int i) {
              final SellerStat s = entries[i];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: DSColor.card,
                  borderRadius: BorderRadius.circular(DSBorderRadius.card),
                  border: Border.all(color: DSColor.onSurface07, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      s.value,
                      style: const TextStyle(
                        fontFamily: dsFontFamily,
                        fontSize: 24,
                        fontWeight: DSFontWeight.bold,
                        color: DSColor.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.label,
                      style: const TextStyle(
                        fontFamily: dsFontFamily,
                        fontSize: DSFontSize.bodySmall,
                        color: DSColor.onSurface45,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
