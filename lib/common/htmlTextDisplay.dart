// import 'package:flutter/material.dart';
// import 'package:flutter_html/flutter_html.dart';

// class HtmlTextDisplay extends StatelessWidget {
//   final String htmlText;

//   HtmlTextDisplay({required this.htmlText});

//   @override
//   Widget build(BuildContext context) {
//     return Html(
//       data: htmlText,
//       shrinkWrap: true,
//       // onLinkTap: (url, context, attributes, element) {
//       //   // Handle link taps here if needed
//       // },
//       // onImageError: (exception, stackTrace) {
//       //   // Handle image errors here if needed
//       // },

//     );
//   }
// }

// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
// ignore: depend_on_referenced_packages, library_prefixes
import 'package:html/parser.dart' as htmlParser;
import 'package:url_launcher/url_launcher.dart';

class HtmlTextDisplay extends StatelessWidget {
  final String htmlText;

  const HtmlTextDisplay({super.key, required this.htmlText});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: HtmlWidget(
        htmlText,

        // webView: false, // Disable web view (table rendering is handled by the package)
      ),
    );
  }
}

class HtmlTextDisplayOneLine extends StatelessWidget {
  final String htmlText;
  final int maxLines;

  const HtmlTextDisplayOneLine({
    super.key,
    required this.htmlText,
    this.maxLines = 1, // Default maxLines
  });

  /// Function to extract plain text from HTML
  String extractPlainText(String htmlString) {
    var document = htmlParser.parse(htmlString);
    return document.body?.text.trim() ?? "";
  }

  @override
  Widget build(BuildContext context) {
    String plainText = extractPlainText(htmlText);

    return Text(
      plainText.isNotEmpty ? plainText : "No message", // Handle empty text
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis, // Add "..." if text overflows
      style: const TextStyle(fontSize: 14.0, color: Colors.black),
    );
  }
}

class HtmlTextDisplayMultiLine extends StatelessWidget {
  final String htmlText;

  const HtmlTextDisplayMultiLine({
    super.key,
    required this.htmlText,
  });

  /// Extract plain text from HTML
  String extractPlainText(String htmlString) {
    var document = htmlParser.parse(htmlString);
    return document.body?.text.trim() ?? "";
  }

  @override
  Widget build(BuildContext context) {
    final plainText = extractPlainText(htmlText);

    if (plainText.isEmpty) {
      return const Text(
        "No message",
        style: TextStyle(fontSize: 14, color: Colors.black),
      );
    }

    return Linkify(
      text: plainText,
      options: const LinkifyOptions(
        removeWww: false,
        looseUrl: true,
      ),
      style: const TextStyle(
        fontSize: 14.0,
        color: Colors.black,
      ),
      linkStyle: const TextStyle(
        color: Colors.blue,
        decoration: TextDecoration.underline,
      ),
      onOpen: (link) async {
        final uri = Uri.parse(link.url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
        }
      },
    );

    /*    return Linkify(
      text: plainText,
      softWrap: true,
      style: const TextStyle(
        fontSize: 14.0,
        color: Colors.black,
      ),
      linkStyle: const TextStyle(
        color: Colors.blue,
        decoration: TextDecoration.underline,
      ),
      onOpen: (link) async {
        final uri = Uri.parse(link.url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
        }
      },
    );
   */
  }
}

/* 
class HtmlTextDisplayMultiLine extends StatelessWidget {
  final String htmlText;
  // final int maxLines;

  const HtmlTextDisplayMultiLine({
    super.key,
    required this.htmlText,

  });

  /// Function to extract plain text from HTML
  String extractPlainText(String htmlString) {
    var document = htmlParser.parse(htmlString);
    return document.body?.text.trim() ?? "";
  }

  @override
  Widget build(BuildContext context) {
    String plainText = extractPlainText(htmlText);

    return Text(
      plainText.isNotEmpty ? plainText : "No message", // Handle empty text
       softWrap: true,          //   allows multi-line
      maxLines: null,  
      // overflow: TextOverflow.ellipsis, // Add "..." if text overflows
      style: const TextStyle(fontSize: 14.0, color: Colors.black),
    );
  }
}
 */