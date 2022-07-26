import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/src/channel_info.dart';
import 'package:stream_chat_flutter/src/extension.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// Bottom Sheet with options
@Deprecated("Use 'StreamChannelInfoBottomSheet' instead")
class ChannelBottomSheet extends StatefulWidget {
  /// Constructor for creating bottom sheet
  const ChannelBottomSheet({super.key, this.onViewInfoTap});

  /// Callback when 'View Info' is tapped
  final VoidCallback? onViewInfoTap;

  @override
  _ChannelBottomSheetState createState() => _ChannelBottomSheetState();
}

// ignore: deprecated_member_use_from_same_package
class _ChannelBottomSheetState extends State<ChannelBottomSheet> {
  bool _showActions = true;

  late StreamChannelState _streamChannelState;
  late StreamChannelPreviewThemeData _channelPreviewThemeData;
  late StreamChatThemeData _streamChatThemeData;
  late StreamChatState _streamChatState;

  @override
  Widget build(BuildContext context) {
    final channel = _streamChannelState.channel;

    final members = channel.state?.members ?? [];

    final userAsMember = members
        .firstWhere((e) => e.user?.id == _streamChatState.currentUser?.id);

    return Material(
      color: _streamChatThemeData.colorTheme.barsBg,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: !_showActions
          ? const SizedBox()
          : ListView(
              shrinkWrap: true,
              children: [
                const SizedBox(
                  height: 24,
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: StreamChannelName(
                      channel: channel,
                      textStyle: _streamChatThemeData.textTheme.headlineBold,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Center(
                  child: StreamChannelInfo(
                    showTypingIndicator: false,
                    channel: _streamChannelState.channel,
                    textStyle: _channelPreviewThemeData.subtitleStyle,
                  ),
                ),
                const SizedBox(
                  height: 17,
                ),
                if (channel.isDistinct && channel.memberCount == 2)
                  Column(
                    children: [
                      StreamUserAvatar(
                        user: members
                            .firstWhere(
                              (e) => e.user?.id != userAsMember.user?.id,
                            )
                            .user!,
                        constraints: const BoxConstraints(
                          maxHeight: 64,
                          maxWidth: 64,
                        ),
                        borderRadius: BorderRadius.circular(32),
                        onlineIndicatorConstraints:
                            BoxConstraints.tight(const Size(12, 12)),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Text(
                        members
                                .firstWhere(
                                  (e) => e.user?.id != userAsMember.user?.id,
                                )
                                .user
                                ?.name ??
                            '',
                        style: _streamChatThemeData.textTheme.footnoteBold,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                if (!(channel.isDistinct && channel.memberCount == 2))
                  Container(
                    height: 94,
                    alignment: Alignment.center,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: members.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          children: [
                            StreamUserAvatar(
                              user: members[index].user!,
                              constraints: const BoxConstraints.tightFor(
                                height: 64,
                                width: 64,
                              ),
                              borderRadius: BorderRadius.circular(32),
                              onlineIndicatorConstraints:
                                  BoxConstraints.tight(const Size(12, 12)),
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            Text(
                              members[index].user?.name ?? '',
                              style:
                                  _streamChatThemeData.textTheme.footnoteBold,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(
                  height: 24,
                ),
                StreamOptionListTile(
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: StreamSvgIcon.user(
                      color: _streamChatThemeData.colorTheme.textLowEmphasis,
                    ),
                  ),
                  title: context.translations.viewInfoLabel,
                  onTap: widget.onViewInfoTap,
                ),
                if (!channel.isDistinct &&
                    channel.ownCapabilities
                        .contains(PermissionType.leaveChannel))
                  StreamOptionListTile(
                    leading: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: StreamSvgIcon.userRemove(
                        color: _streamChatThemeData.colorTheme.textLowEmphasis,
                      ),
                    ),
                    title: context.translations.leaveGroupLabel,
                    onTap: () async {
                      setState(() {
                        _showActions = false;
                      });
                      await _showLeaveDialog();
                      setState(() {
                        _showActions = true;
                      });
                    },
                  ),
                if (channel.ownCapabilities
                    .contains(PermissionType.deleteChannel))
                  StreamOptionListTile(
                    leading: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: StreamSvgIcon.delete(
                        color: _streamChatThemeData.colorTheme.accentError,
                      ),
                    ),
                    title: context.translations.deleteConversationLabel,
                    titleColor: _streamChatThemeData.colorTheme.accentError,
                    onTap: () async {
                      setState(() {
                        _showActions = false;
                      });
                      await _showDeleteDialog();
                      setState(() {
                        _showActions = true;
                      });
                    },
                  ),
                StreamOptionListTile(
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: StreamSvgIcon.closeSmall(
                      color: _streamChatThemeData.colorTheme.textLowEmphasis,
                    ),
                  ),
                  title: context.translations.cancelLabel,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
    );
  }

  @override
  void didChangeDependencies() {
    _streamChannelState = StreamChannel.of(context);
    _streamChatThemeData = StreamChatTheme.of(context);
    _channelPreviewThemeData = StreamChannelPreviewTheme.of(context);
    _streamChatState = StreamChat.of(context);
    super.didChangeDependencies();
  }

  Future<void> _showDeleteDialog() async {
    final res = await showConfirmationDialog(
      context,
      title: context.translations.deleteConversationLabel,
      okText: context.translations.deleteLabel,
      question: context.translations.deleteConversationQuestion,
      cancelText: context.translations.cancelLabel,
      icon: StreamSvgIcon.delete(
        color: _streamChatThemeData.colorTheme.accentError,
      ),
    );
    final channel = _streamChannelState.channel;
    if (res == true) {
      await channel.delete();
      Navigator.pop(context);
    }
  }

  Future<void> _showLeaveDialog() async {
    final res = await showConfirmationDialog(
      context,
      title: context.translations.leaveConversationLabel,
      okText: context.translations.leaveLabel,
      question: context.translations.leaveConversationQuestion,
      cancelText: context.translations.cancelLabel,
      icon: StreamSvgIcon.userRemove(
        color: _streamChatThemeData.colorTheme.accentError,
      ),
    );
    if (res == true) {
      final channel = _streamChannelState.channel;
      final user = _streamChatState.currentUser;
      if (user != null) {
        await channel.removeMembers([user.id]);
      }
      Navigator.pop(context);
    }
  }
}
