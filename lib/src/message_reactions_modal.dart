import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/src/extension.dart';
import 'package:stream_chat_flutter/src/reaction_bubble.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// {@macro message_reactions_modal}
@Deprecated("Use 'StreamMessageReactionsModal' instead")
typedef MessageReactionsModal = StreamMessageReactionsModal;

/// {@template message_reactions_modal}
/// Modal widget for displaying message reactions
/// {@endtemplate}
class StreamMessageReactionsModal extends StatelessWidget {
  /// Constructor for creating a [StreamMessageReactionsModal] reactions
  const StreamMessageReactionsModal({
    super.key,
    required this.message,
    required this.messageWidget,
    required this.messageTheme,
    this.showReactions,
    this.reverse = false,
    this.onUserAvatarTap,
  });

  /// Widget that shows the message
  final Widget messageWidget;

  /// Message to display reactions of
  final Message message;

  /// [StreamMessageThemeData] to apply to [message]
  final StreamMessageThemeData messageTheme;

  /// Flag to reverse message
  final bool reverse;

  /// Flag to show reactions on message
  final bool? showReactions;

  /// Callback when user avatar is tapped
  final void Function(User)? onUserAvatarTap;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = StreamChat.of(context).currentUser;
    final _userPermissions = StreamChannel.of(context).channel.ownCapabilities;

    final hasReactionPermission =
        _userPermissions.contains(PermissionType.sendReaction);

    final roughMaxSize = size.width * 2 / 3;
    var messageTextLength = message.text!.length;
    if (message.quotedMessage != null) {
      var quotedMessageLength = message.quotedMessage!.text!.length + 40;
      if (message.quotedMessage!.attachments.isNotEmpty) {
        quotedMessageLength += 40;
      }
      if (quotedMessageLength > messageTextLength) {
        messageTextLength = quotedMessageLength;
      }
    }
    final roughSentenceSize = messageTextLength *
        (messageTheme.messageTextStyle?.fontSize ?? 1) *
        1.2;
    final divFactor = message.attachments.isNotEmpty
        ? 1
        : (roughSentenceSize == 0 ? 1 : (roughSentenceSize / roughMaxSize));

    final numberOfReactions = StreamChatTheme.of(context).reactionIcons.length;
    final shiftFactor =
        numberOfReactions < 5 ? (5 - numberOfReactions) * 0.1 : 0.0;

    final child = Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if ((showReactions ?? hasReactionPermission) &&
                  (message.status == MessageSendingStatus.sent))
                Align(
                  alignment: Alignment(
                    user!.id == message.user!.id
                        ? (divFactor >= 1.0
                            ? -0.2 - shiftFactor
                            : (1.2 - divFactor))
                        : (divFactor >= 1.0
                            ? shiftFactor + 0.2
                            : -(1.2 - divFactor)),
                    0,
                  ),
                  child: StreamReactionPicker(
                    message: message,
                  ),
                ),
              const SizedBox(height: 8),
              IgnorePointer(
                child: messageWidget,
              ),
              if (message.latestReactions?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                _buildReactionCard(
                  context,
                  user,
                ),
              ],
            ],
          ),
        ),
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => Navigator.maybePop(context),
      child: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 10,
                sigmaY: 10,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: StreamChatTheme.of(context).colorTheme.overlay,
                ),
              ),
            ),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutBack,
            builder: (context, val, widget) => Transform.scale(
              scale: val,
              child: widget,
            ),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildReactionCard(BuildContext context, User? user) {
    final chatThemeData = StreamChatTheme.of(context);
    return Card(
      color: chatThemeData.colorTheme.barsBg,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.translations.messageReactionsLabel,
              style: chatThemeData.textTheme.headlineBold,
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: message.latestReactions!
                      .map((e) => _buildReaction(
                            e,
                            user!,
                            context,
                          ))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReaction(
    Reaction reaction,
    User currentUser,
    BuildContext context,
  ) {
    final isCurrentUser = reaction.user?.id == currentUser.id;
    final chatThemeData = StreamChatTheme.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints.loose(const Size(
        64,
        98,
      )),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              StreamUserAvatar(
                onTap: onUserAvatarTap,
                user: reaction.user!,
                constraints: const BoxConstraints.tightFor(
                  height: 64,
                  width: 64,
                ),
                onlineIndicatorConstraints: const BoxConstraints.tightFor(
                  height: 12,
                  width: 12,
                ),
                borderRadius: BorderRadius.circular(32),
              ),
              Positioned(
                bottom: 6,
                left: isCurrentUser ? -3 : null,
                right: isCurrentUser ? -3 : null,
                child: Align(
                  alignment:
                      reverse ? Alignment.centerRight : Alignment.centerLeft,
                  child: StreamReactionBubble(
                    reactions: [reaction],
                    flipTail: !reverse,
                    borderColor:
                        messageTheme.reactionsBorderColor ?? Colors.transparent,
                    backgroundColor: messageTheme.reactionsBackgroundColor ??
                        Colors.transparent,
                    maskColor: chatThemeData.colorTheme.barsBg,
                    tailCirclesSpacing: 1,
                    highlightOwnReactions: false,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reaction.user!.name.split(' ')[0],
            style: chatThemeData.textTheme.footnoteBold,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
