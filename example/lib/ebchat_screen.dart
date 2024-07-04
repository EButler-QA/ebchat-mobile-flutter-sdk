import 'package:ebchat/ebchat.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:internalsdkexample/ebchat_provider.dart';

class EBChatScreen extends StatefulWidget {
  final String eButlerEBChatKey;
  final String? botFlowId;
  final String? initialMessage;
  const EBChatScreen(
      {super.key,
      required this.eButlerEBChatKey,
      this.botFlowId,
      this.initialMessage});
  @override
  State<EBChatScreen> createState() => _EBChatScreenState();
}

class _EBChatScreenState extends State<EBChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left_rounded,
            size: 30.0,
          ),
          onPressed: () async {
            context.read<EbchatProvider>().navigateEbchat(false);
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          "Talk to customer service",
        ),
        actions: const [],
        centerTitle: true,
        elevation: 0.0,
      ),
      body: EBChatWidget(
        key: ValueKey(widget.eButlerEBChatKey),
        ebchatToken: widget.eButlerEBChatKey,
        client: context.read<EbchatProvider>().ebchatClient!,
        currentUser: context.read<EbchatProvider>().currentConnectedUser!,
        companyLogo: 'default',
      ),
    );
  }
}
