import 'package:collection/collection.dart'
    show IterableExtension, ListEquality;
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/src/extension.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// {@template channel_preview}
/// ![screenshot](https://raw.githubusercontent.com/GetStream/stream-chat-flutter/master/packages/stream_chat_flutter/screenshots/channel_preview.png)
/// ![screenshot](https://raw.githubusercontent.com/GetStream/stream-chat-flutter/master/packages/stream_chat_flutter/screenshots/channel_preview_paint.png)
///
/// It shows the current [Channel] preview.
///
/// The widget uses a [StreamBuilder] to render the channel information
/// image as soon as it updates.
///
/// Usually you don't use this widget as it's the default channel preview
/// used by [StreamChannelListView].
///
/// The widget renders the ui based on the first ancestor of type
/// [StreamChatTheme].
/// Modify it to change the widget appearance.
/// {@endtemplate}
@Deprecated("Use 'StreamChannelListTile' instead")
class ChannelPreview extends StatelessWidget {
  /// Constructor for creating [ChannelPreview]
  const ChannelPreview({
    required this.channel,
    super.key,
    this.onTap,
    this.onLongPress,
    this.onImageTap,
    this.title,
    this.subtitle,
    this.leading,
    this.sendingIndicator,
    this.trailing,
  });

  /// Function called when tapping this widget
  final void Function(Channel)? onTap;

  /// Function called when long pressing this widget
  final void Function(Channel)? onLongPress;

  /// Channel displayed
  final Channel channel;

  /// The function called when the image is tapped
  final VoidCallback? onImageTap;

  /// Widget rendering the title
  final Widget? title;

  /// Widget rendering the subtitle
  final Widget? subtitle;

  /// Widget rendering the leading element, by default
  /// it shows the [StreamChannelAvatar]
  final Widget? leading;

  /// Widget rendering the trailing element,
  /// by default it shows the last message date
  final Widget? trailing;

  /// Widget rendering the sending indicator,
  /// by default it uses the [StreamSendingIndicator] widget
  final Widget? sendingIndicator;

  @override
  Widget build(BuildContext context) {
    final channelPreviewTheme = ChannelPreviewTheme.of(context);
    final streamChatState = StreamChat.of(context);
    return BetterStreamBuilder<bool>(
      stream: channel.isMutedStream,
      initialData: channel.isMuted,
      builder: (context, data) => AnimatedOpacity(
        opacity: data ? 0.5 : 1,
        duration: const Duration(milliseconds: 300),
        child: ListTile(
          visualDensity: VisualDensity.compact,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
          ),
          onTap: () => onTap?.call(channel),
          onLongPress: () => onLongPress?.call(channel),
          leading: leading ??
              StreamChannelAvatar(
                channel: channel,
                onTap: onImageTap,
              ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                child: title ??
                    StreamChannelName(
                      channel: channel,
                      textStyle: channelPreviewTheme.titleStyle,
                    ),
              ),
              BetterStreamBuilder<List<Member>>(
                stream: channel.state?.membersStream,
                initialData: channel.state?.members,
                comparator: const ListEquality().equals,
                builder: (context, members) {
                  if (members.isEmpty ||
                      !members.any((Member e) =>
                          e.user!.id == channel.client.state.currentUser?.id)) {
                    return const SizedBox();
                  }
                  return StreamUnreadIndicator(
                    cid: channel.cid,
                  );
                },
              ),
            ],
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(child: subtitle ?? _buildSubtitle(context)),
              sendingIndicator ??
                  Builder(
                    builder: (context) {
                      final lastMessage =
                          channel.state?.messages.lastWhereOrNull(
                        (m) => !m.isDeleted && !m.shadowed,
                      );
                      if (lastMessage?.user?.id ==
                          streamChatState.currentUser?.id) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: BetterStreamBuilder<List<Read>>(
                            stream: channel.state?.readStream,
                            initialData: channel.state?.read,
                            builder: (context, data) {
                              final readList = data.where((it) =>
                                  it.user.id !=
                                      channel.client.state.currentUser?.id &&
                                  (it.lastRead
                                          .isAfter(lastMessage!.createdAt) ||
                                      it.lastRead.isAtSameMomentAs(
                                        lastMessage.createdAt,
                                      )));
                              final isMessageRead = readList.length >=
                                  (channel.memberCount ?? 0) - 1;
                              return StreamSendingIndicator(
                                message: lastMessage!,
                                size: channelPreviewTheme.indicatorIconSize,
                                isMessageRead: isMessageRead,
                              );
                            },
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
              trailing ?? _buildDate(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDate(BuildContext context) => BetterStreamBuilder<DateTime>(
        stream: channel.lastMessageAtStream,
        initialData: channel.lastMessageAt,
        builder: (context, data) {
          final lastMessageAt = data.toLocal();

          String stringDate;
          final now = DateTime.now();

          final startOfDay = DateTime(now.year, now.month, now.day);

          if (lastMessageAt.millisecondsSinceEpoch >=
              startOfDay.millisecondsSinceEpoch) {
            stringDate = Jiffy(lastMessageAt.toLocal()).jm;
          } else if (lastMessageAt.millisecondsSinceEpoch >=
              startOfDay
                  .subtract(const Duration(days: 1))
                  .millisecondsSinceEpoch) {
            stringDate = context.translations.yesterdayLabel;
          } else if (startOfDay.difference(lastMessageAt).inDays < 7) {
            stringDate = Jiffy(lastMessageAt.toLocal()).EEEE;
          } else {
            stringDate = Jiffy(lastMessageAt.toLocal()).yMd;
          }

          return Text(
            stringDate,
            style: ChannelPreviewTheme.of(context).lastMessageAtStyle,
          );
        },
      );

  Widget _buildSubtitle(BuildContext context) {
    final channelPreviewTheme = ChannelPreviewTheme.of(context);
    if (channel.isMuted) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          StreamSvgIcon.mute(
            size: 16,
          ),
          Text(
            '  ${context.translations.channelIsMutedText}',
            style: channelPreviewTheme.subtitleStyle,
          ),
        ],
      );
    }
    return StreamTypingIndicator(
      channel: channel,
      alternativeWidget: _buildLastMessage(context),
      style: channelPreviewTheme.subtitleStyle,
    );
  }

  Widget _buildLastMessage(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: BetterStreamBuilder<List<Message>>(
          stream: channel.state!.messagesStream,
          initialData: channel.state!.messages,
          builder: (context, data) {
            final lastMessage =
                data.lastWhereOrNull((m) => !m.shadowed && !m.isDeleted);
            if (lastMessage == null) {
              return const SizedBox();
            }

            var text = lastMessage.text;
            final parts = <String>[
              ...lastMessage.attachments.map((e) {
                if (e.type == 'image') {
                  return '📷';
                } else if (e.type == 'video') {
                  return '🎬';
                } else if (e.type == 'giphy') {
                  return '[GIF]';
                }
                return e == lastMessage.attachments.last
                    ? (e.title ?? 'File')
                    : '${e.title ?? 'File'} , ';
              }),
              lastMessage.text ?? '',
            ];

            text = parts.join(' ');

            final channelPreviewTheme = ChannelPreviewTheme.of(context);
            return Text.rich(
              _getDisplayText(
                text,
                lastMessage.mentionedUsers,
                lastMessage.attachments,
                channelPreviewTheme.subtitleStyle?.copyWith(
                  color: channelPreviewTheme.subtitleStyle?.color,
                  fontStyle: (lastMessage.isSystem || lastMessage.isDeleted)
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
                channelPreviewTheme.subtitleStyle?.copyWith(
                  color: channelPreviewTheme.subtitleStyle?.color,
                  fontStyle: (lastMessage.isSystem || lastMessage.isDeleted)
                      ? FontStyle.italic
                      : FontStyle.normal,
                  fontWeight: FontWeight.bold,
                ),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
            );
          },
        ),
      );

  TextSpan _getDisplayText(
    String text,
    List<User> mentions,
    List<Attachment> attachments,
    TextStyle? normalTextStyle,
    TextStyle? mentionsTextStyle,
  ) {
    final textList = text.split(' ');
    final resList = <TextSpan>[];
    for (final e in textList) {
      if (mentions.isNotEmpty &&
          mentions.any((element) => '@${element.name}' == e)) {
        resList.add(TextSpan(
          text: '$e ',
          style: mentionsTextStyle,
        ));
      } else if (attachments.isNotEmpty &&
          attachments
              .where((e) => e.title != null)
              .any((element) => element.title == e)) {
        resList.add(TextSpan(
          text: '$e ',
          style: normalTextStyle?.copyWith(fontStyle: FontStyle.italic),
        ));
      } else {
        resList.add(TextSpan(
          text: e == textList.last ? e : '$e ',
          style: normalTextStyle,
        ));
      }
    }

    return TextSpan(children: resList);
  }
}
