import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:internalsdkexample/ebchat_provider.dart';

class AsyncButtonWidget extends StatefulWidget {
  const AsyncButtonWidget(
      {super.key, this.chatKey, this.channelId, required this.buttonText});
  final String? chatKey;
  final String? channelId;
  final String buttonText;
  @override
  State<AsyncButtonWidget> createState() => _AsyncButtonWidgetState();
}

class _AsyncButtonWidgetState extends State<AsyncButtonWidget> {
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        onPressed: loading
            ? null
            : () async {
                setState(() {
                  loading = true;
                });
                final provider = context.read<EbchatProvider>();
                if (widget.chatKey != null) {
                  await provider.getEbchatClient(widget.chatKey!);
                  await context
                      .read<EbchatProvider>()
                      .connectUserToEbchat(context, EbchatProvider().key);
                  provider.navigateEbchat(true);
                } else if (widget.channelId != null) {
                  await provider.handlStreamNotification(
                      context, widget.channelId!);
                }

                setState(() {
                  loading = false;
                });
              },
        child: SizedBox(
          height: 50,
          child: loading
              ? const CircularProgressIndicator(
                  color: Colors.white,
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.chat),
                    const SizedBox(width: 7),
                    Text(widget.buttonText,
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 13))
                  ],
                ),
        ),
      ),
    );
  }
}
