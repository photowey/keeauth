import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:keeauth/core/constant/app_constants.dart';
import 'package:keeauth/core/utils/keys.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:keeauth/l10n/app_localizations.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  Future<void> _launch(BuildContext context, Uri uri) async {
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _copyAndHint(context, uri);
      }
    } catch (_) {
      _copyAndHint(context, uri);
    }
  }

  void _copyAndHint(BuildContext context, Uri uri) {
    Clipboard.setData(ClipboardData(text: uri.toString()));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.linkCopied ??
                'Link copied — please open in browser',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.about ?? "About",
          key: ValueKey(AboutUsKeys.titleAbout),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            Card(
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.bug_report, color: Colors.black),
                    title: Text(
                      l10n?.reportIssue ?? "Report an Issue",
                      key: ValueKey(AboutUsKeys.titleReport),
                    ),
                    subtitle: Text(
                      l10n?.havingIssue ?? "Having an issue? Report it here",
                      key: ValueKey(AboutUsKeys.subtitleReport),
                    ),
                    onTap: () => _launch(context, Uri.parse(Author.issueUrl)),
                  ),
                  ListTile(
                    leading: Icon(Icons.update, color: Colors.black),
                    title: Text(l10n?.version ?? "Version"),
                    subtitle: FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snapshot) {
                        final versionName = snapshot.data?.version ?? '1.0.0';
                        return Text(
                          versionName,
                          key: ValueKey(AboutUsKeys.versionNumber),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, left: 16.0),
                    child: Text(
                      l10n?.author ?? "Author",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: Fonts.fontMedium,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.perm_identity, color: Colors.black),
                    title: Text(
                      "changjun",
                      key: ValueKey(AboutUsKeys.authorName),
                    ),
                    subtitle: Text(
                      "photowey",
                      key: ValueKey(AboutUsKeys.authorUsername),
                    ),
                    onTap: () => _launch(context, Uri.parse(Author.githubUrl)),
                  ),
                  ListTile(
                    leading: Icon(Icons.bug_report, color: Colors.black),
                    title: Text(l10n?.forkOnGithub ?? "Fork on Github"),
                    onTap: () => _launch(context, Uri.parse(Author.projectUrl)),
                  ),
                  ListTile(
                    leading: Icon(Icons.email, color: Colors.black),
                    title: Text(l10n?.sendEmail ?? "Send an Email"),
                    subtitle: Text(
                      Author.email,
                      key: ValueKey(AboutUsKeys.authorEmail),
                    ),
                    onTap: () => _launch(context, Uri.parse(Author.emailUrl)),
                  ),
                ],
              ),
            ),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, left: 16.0),
                    child: Text(
                      l10n?.askQuestion ?? "Ask Question?",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: Fonts.fontMedium,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        IconButton(
                          icon: Image.asset(
                            "assets/images/github.png",
                            scale: 8.75,
                          ),
                          onPressed: () => _launch(context, Uri.parse(Author.githubUrl)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, left: 16.0),
                    child: Text(
                      l10n?.apacheLicense ?? "Apache License",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: Fonts.fontMedium,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ListTile(
                      subtitle: Text(
                        "Copyright (c) 2025-present photowey<photowey@gmail.com>"
                        '\n\nLicensed under the GNU General Public License v3.0.\n'
                        'See https://www.gnu.org/licenses/gpl-3.0.html'
                        '\n\nKeeAuth is a derivative work of Stratum Auth '
                        '(github.com/stratumauth/app), also GPL 3.0.',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
