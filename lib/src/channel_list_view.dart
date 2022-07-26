// ignore: lines_longer_than_80_chars
// ignore_for_file: deprecated_member_use_from_same_package, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stream_chat_flutter/src/extension.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// Callback called when tapping on a channel
typedef ChannelTapCallback = void Function(Channel, Widget?);

/// Callback called when tapping on a channel
typedef ChannelInfoCallback = void Function(Channel);

/// Builder used to create a custom [StreamChannelPreview] from a [Channel]
typedef ChannelPreviewBuilder = Widget Function(BuildContext, Channel);

/// Callback for when 'View Info' is tapped
typedef ViewInfoCallback = void Function(Channel);

/// ![screenshot](https://raw.githubusercontent.com/GetStream/stream-chat-flutter/master/packages/stream_chat_flutter/screenshots/channel_list_view.png)
/// ![screenshot](https://raw.githubusercontent.com/GetStream/stream-chat-flutter/master/packages/stream_chat_flutter/screenshots/channel_list_view_paint.png)
///
/// It shows the list of current channels.
///
/// ```dart
/// class ChannelListPage extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       body: ChannelListView(
///         filter: {
///           'members': {
///             '\$in': [StreamChat.of(context).user.id],
///           }
///         },
///         sort: [SortOption('last_message_at')],
///         pagination: PaginationParams(
///           limit: 20,
///         ),
///         channelWidget: ChannelPage(),
///       ),
///     );
///   }
/// }
/// ```
///
///
/// Make sure to have a [StreamChat] ancestor in order to provide the
/// information about the channels.
/// The widget uses a [ListView.custom] to render the list of channels.
///
/// The widget components render the ui based on the first ancestor of
/// type [StreamChatTheme].
/// Modify it to change the widget appearance.
@Deprecated("Use 'StreamChannelListView' instead")
class ChannelListView extends StatefulWidget {
  /// Instantiate a new ChannelListView
  @Deprecated("Use 'StreamChannelListView' instead")
  ChannelListView({
    super.key,
    this.filter,
    this.sort,
    this.state = true,
    this.watch = true,
    this.presence = false,
    this.memberLimit,
    this.messageLimit,
    @Deprecated(
      "'pagination' is deprecated and shouldn't be used. "
      "This property is no longer used, Please use 'limit' instead",
    )
        this.pagination,
    int? limit,
    this.onChannelTap,
    this.onChannelLongPress,
    this.channelWidget,
    this.channelPreviewBuilder,
    this.separatorBuilder,
    this.onImageTap,
    this.onStartChatPressed,
    this.swipeToAction = false,
    this.pullToRefresh = true,
    this.crossAxisCount = 1,
    this.padding,
    this.selectedChannels = const [],
    this.onViewInfoTap,
    this.errorBuilder,
    this.emptyBuilder,
    this.loadingBuilder,
    this.listBuilder,
    this.onMoreDetailsPressed,
    this.onDeletePressed,
    this.swipeActions,
    this.channelListController,
  }) : limit = limit ?? pagination?.limit ?? 25;

  /// If true a default swipe to action behaviour will be added to this widget
  final bool swipeToAction;

  /// The query filters to use.
  /// You can query on any of the custom fields you've defined on the [Channel].
  /// You can also filter other built-in channel fields.
  final Filter? filter;

  /// The sorting used for the channels matching the filters.
  /// Sorting is based on field and direction, multiple sorting options
  /// can be provided.
  /// You can sort based on last_updated, last_message_at, updated_at,
  /// created_at or member_count.
  /// Direction can be ascending or descending.
  final List<SortOption<ChannelModel>>? sort;

  /// If true returns the Channel state
  final bool state;

  /// If true listen to changes to this Channel in real time.
  final bool watch;

  /// If true you’ll receive user presence updates via the websocket events
  final bool presence;

  /// Number of members to fetch in each channel
  final int? memberLimit;

  /// Number of messages to fetch in each channel
  final int? messageLimit;

  /// Pagination parameters
  /// limit: the number of channels to return (max is 30)
  /// offset: the offset (max is 1000)
  /// message_limit: how many messages should be included to each channel
  @Deprecated(
    "'pagination' is deprecated and shouldn't be used. "
    "This property is no longer used, Please use 'limit' instead",
  )
  final PaginationParams? pagination;

  /// The amount of channels requested per API call.
  final int limit;

  /// Function called when tapping on a channel
  /// By default it calls [Navigator.push] building a [MaterialPageRoute]
  /// with the widget [channelWidget] as child.
  final ChannelTapCallback? onChannelTap;

  /// Function called when long pressing on a channel
  final Function(Channel)? onChannelLongPress;

  /// Widget used when opening a channel
  final Widget? channelWidget;

  /// Builder used to create a custom channel preview
  final ChannelPreviewBuilder? channelPreviewBuilder;

  /// Builder used to create a custom item separator
  final Function(BuildContext, int)? separatorBuilder;

  /// The function called when the image is tapped
  final Function(Channel)? onImageTap;

  /// Set it to false to disable the pull-to-refresh widget
  final bool pullToRefresh;

  /// Callback used in the default empty list widget
  final VoidCallback? onStartChatPressed;

  /// The number of children in the cross axis.
  final int crossAxisCount;

  /// The amount of space by which to inset the children.
  final EdgeInsetsGeometry? padding;

  /// List of selected channels which are displayed differently
  final List<Channel> selectedChannels;

  /// Callback for when 'View Info' is tapped
  final ViewInfoCallback? onViewInfoTap;

  /// The builder that will be used in case of error
  final ErrorBuilder? errorBuilder;

  /// The builder that will be used in case of loading
  final WidgetBuilder? loadingBuilder;

  /// The builder which is used when list of channels loads
  final Function(BuildContext, List<Channel>)? listBuilder;

  /// The builder used when the channel list is empty.
  final WidgetBuilder? emptyBuilder;

  /// Callback used when the more details slidable option is pressed
  final ChannelInfoCallback? onMoreDetailsPressed;

  /// Callback used when the delete slidable option is pressed
  final ChannelInfoCallback? onDeletePressed;

  /// List of actions for slidable
  final List<SwipeAction>? swipeActions;

  /// A [ChannelListController] allows reloading and pagination.
  /// Use [ChannelListController.loadData] and
  /// [ChannelListController.paginateData] respectively for reloading and
  /// pagination.
  final ChannelListController? channelListController;

  @override
  _ChannelListViewState createState() => _ChannelListViewState();
}

class _ChannelListViewState extends State<ChannelListView> {
  late final _defaultController = ChannelListController();

  ChannelListController get _channelListController =>
      widget.channelListController ?? _defaultController;

  @override
  Widget build(BuildContext context) {
    Widget child = ChannelListCore(
      filter: widget.filter,
      sort: widget.sort,
      state: widget.state,
      watch: widget.watch,
      presence: widget.presence,
      memberLimit: widget.memberLimit,
      messageLimit: widget.messageLimit,
      limit: widget.limit,
      channelListController: _channelListController,
      listBuilder: widget.listBuilder ?? _buildListView,
      emptyBuilder: widget.emptyBuilder ?? _buildEmptyWidget,
      errorBuilder: widget.errorBuilder ?? _buildErrorWidget,
      loadingBuilder: widget.loadingBuilder ?? _buildLoadingWidget,
    );

    if (widget.pullToRefresh) {
      child = RefreshIndicator(
        onRefresh: () => _channelListController.loadData!(),
        child: child,
      );
    }

    child = LazyLoadScrollView(
      onEndOfPage: () => _channelListController.paginateData!(),
      child: child,
    );

    final backgroundColor =
        StreamChannelListViewTheme.of(context).backgroundColor;

    if (backgroundColor != null) {
      return ColoredBox(
        color: backgroundColor,
        child: child,
      );
    }

    return child;
  }

  Widget _buildListView(BuildContext context, List<Channel> channels) {
    if (widget.crossAxisCount > 1) {
      return GridView.builder(
        padding: widget.padding,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.crossAxisCount,
        ),
        itemCount: channels.length,
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) =>
            _gridItemBuilder(context, index, channels),
      );
    }
    return SlidableAutoCloseBehavior(
      child: ListView.separated(
        padding: widget.padding,
        physics: const AlwaysScrollableScrollPhysics(),
        // all channels + progress loader
        itemCount: channels.length + 1,
        separatorBuilder: (_, index) {
          if (widget.separatorBuilder != null) {
            return widget.separatorBuilder!(context, index);
          }
          return _separatorBuilder(context, index);
        },
        itemBuilder: (context, index) =>
            _listItemBuilder(context, index, channels),
      ),
    );
  }

  Widget _buildEmptyWidget(BuildContext context) => LayoutBuilder(
        builder: (context, viewportConstraints) {
          final chatThemeData = StreamChatTheme.of(context);
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Stack(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewportConstraints.maxHeight,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: StreamSvgIcon.message(
                          size: 136,
                          color: chatThemeData.colorTheme.disabled,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          context.translations.letsStartChattingLabel,
                          style: chatThemeData.textTheme.headline,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 52,
                        ),
                        child: Text(
                          context.translations.sendingFirstMessageLabel,
                          textAlign: TextAlign.center,
                          style: chatThemeData.textTheme.body.copyWith(
                            color: chatThemeData.colorTheme.textLowEmphasis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.onStartChatPressed != null)
                  Positioned(
                    right: 0,
                    left: 0,
                    bottom: 32,
                    child: Center(
                      child: TextButton(
                        onPressed: widget.onStartChatPressed,
                        child: Text(
                          context.translations.startAChatLabel,
                          style: chatThemeData.textTheme.bodyBold.copyWith(
                            color: chatThemeData.colorTheme.accentPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      );

  Widget _buildLoadingWidget(BuildContext context) => ListView(
        padding: widget.padding,
        physics: const AlwaysScrollableScrollPhysics(),
        children: List.generate(
          25,
          (i) {
            if (widget.crossAxisCount == 1) {
              if (i % 2 != 0) {
                if (widget.separatorBuilder != null) {
                  return widget.separatorBuilder!(context, i);
                }
                return _separatorBuilder(context, i);
              }
            }
            return _buildLoadingItem(context);
          },
        ),
      );

  Shimmer _buildLoadingItem(BuildContext context) {
    final chatThemeData = StreamChatTheme.of(context);
    if (widget.crossAxisCount > 1) {
      return Shimmer.fromColors(
        baseColor: chatThemeData.colorTheme.disabled,
        highlightColor: chatThemeData.colorTheme.inputBg,
        child: Column(
          children: [
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int i = 0; i < widget.crossAxisCount; i++)
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints.tightFor(
                      height: 70,
                      width: 70,
                    ),
                  ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
          ],
        ),
      );
    } else {
      return Shimmer.fromColors(
        baseColor: chatThemeData.colorTheme.disabled,
        highlightColor: chatThemeData.colorTheme.inputBg,
        child: ListTile(
          leading: Container(
            decoration: BoxDecoration(
              color: chatThemeData.colorTheme.barsBg,
              shape: BoxShape.circle,
            ),
            constraints: const BoxConstraints.tightFor(
              height: 40,
              width: 40,
            ),
          ),
          contentPadding: const EdgeInsets.only(
            left: 8,
            right: 8,
          ),
          title: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: chatThemeData.colorTheme.barsBg,
                borderRadius: BorderRadius.circular(11),
              ),
              constraints: const BoxConstraints.tightFor(
                height: 16,
                width: 82,
              ),
            ),
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      color: chatThemeData.colorTheme.barsBg,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    constraints: const BoxConstraints.expand(
                      height: 16,
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 16),
                decoration: BoxDecoration(
                  color: chatThemeData.colorTheme.barsBg,
                  borderRadius: BorderRadius.circular(11),
                ),
                constraints: const BoxConstraints.tightFor(
                  height: 16,
                  width: 42,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildErrorWidget(BuildContext context, Object error) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text.rich(
              TextSpan(
                children: [
                  const WidgetSpan(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: 2,
                      ),
                      child: Icon(Icons.error_outline),
                    ),
                  ),
                  TextSpan(text: context.translations.loadingChannelsError),
                ],
              ),
              style: Theme.of(context).textTheme.headline6,
            ),
            TextButton(
              onPressed: () => _channelListController.loadData!(),
              child: Text(context.translations.retryLabel),
            ),
          ],
        ),
      );

  Widget _listItemBuilder(BuildContext context, int i, List<Channel> channels) {
    final channelsBloc = ChannelsBloc.of(context);

    if (i == channels.length) {
      return _buildQueryProgressIndicator(context, channelsBloc);
    }

    final onTap = _getChannelTap(context);
    final chatThemeData = StreamChatTheme.of(context);
    final backgroundColor = chatThemeData.colorTheme.inputBg;
    final channel = channels[i];

    final canDeleteChannel =
        channel.ownCapabilities.contains(PermissionType.deleteChannel);

    final actionPaneChildren =
        widget.swipeActions?.length ?? (canDeleteChannel ? 2 : 1);
    final actionPaneExtentRatio = actionPaneChildren > 5
        ? 1 / actionPaneChildren
        : actionPaneChildren * 0.2;

    return StreamChannel(
      key: ValueKey<String>('CHANNEL-${channel.cid}'),
      channel: channel,
      child: Slidable(
        enabled: widget.swipeToAction,
        endActionPane: ActionPane(
          extentRatio: actionPaneExtentRatio,
          motion: const BehindMotion(),
          children: widget.swipeActions
                  ?.map((e) => CustomSlidableAction(
                        backgroundColor: e.color ?? Colors.white,
                        child: e.iconWidget,
                        onPressed: (_) {
                          e.onTap?.call(channel);
                        },
                      ))
                  .toList() ??
              <Widget>[
                CustomSlidableAction(
                  backgroundColor: backgroundColor,
                  onPressed: widget.onMoreDetailsPressed != null
                      ? (_) {
                          widget.onMoreDetailsPressed!(channel);
                        }
                      : (_) {
                          showModalBottomSheet(
                            clipBehavior: Clip.hardEdge,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(32),
                                topRight: Radius.circular(32),
                              ),
                            ),
                            context: context,
                            builder: (context) => StreamChannel(
                              channel: channel,
                              child: StreamChannelInfoBottomSheet(
                                channel: channel,
                                onViewInfoTap: () {
                                  widget.onViewInfoTap?.call(channel);
                                },
                              ),
                            ),
                          );
                        },
                  child: const Icon(Icons.more_horiz),
                ),
                if (canDeleteChannel)
                  CustomSlidableAction(
                    backgroundColor: backgroundColor,
                    onPressed: widget.onDeletePressed != null
                        ? (_) {
                            widget.onDeletePressed?.call(channel);
                          }
                        : (_) async {
                            final res = await showConfirmationDialog(
                              context,
                              title:
                                  context.translations.deleteConversationLabel,
                              question: context
                                  .translations.deleteConversationQuestion,
                              okText: context.translations.deleteLabel,
                              cancelText: context.translations.cancelLabel,
                              icon: StreamSvgIcon.delete(
                                color: chatThemeData.colorTheme.accentError,
                              ),
                            );
                            if (res == true) {
                              await channel.delete();
                            }
                          },
                    child: StreamSvgIcon.delete(
                      color: chatThemeData.colorTheme.accentError,
                    ),
                  ),
              ],
        ),
        child: widget.channelPreviewBuilder?.call(context, channel) ??
            DecoratedBox(
              decoration: BoxDecoration(
                color: chatThemeData.channelListViewTheme.backgroundColor,
              ),
              child: ChannelPreview(
                onLongPress: widget.onChannelLongPress,
                channel: channel,
                onImageTap: widget.onImageTap != null
                    ? () => widget.onImageTap!(channel)
                    : null,
                onTap: (channel) => onTap(channel, widget.channelWidget),
              ),
            ),
      ),
    );
  }

  ChannelTapCallback _getChannelTap(BuildContext context) {
    ChannelTapCallback onTap;
    if (widget.onChannelTap != null) {
      onTap = widget.onChannelTap!;
    } else {
      onTap = (channel, _) {
        if (widget.channelWidget == null) {
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StreamChannel(
              channel: channel,
              child: widget.channelWidget!,
            ),
          ),
        );
      };
    }
    return onTap;
  }

  Widget _gridItemBuilder(BuildContext context, int i, List<Channel> channels) {
    final channel = channels[i];

    final selected = widget.selectedChannels.contains(channel);

    return Container(
      key: ValueKey<String>('CHANNEL-${channel.id}'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StreamChannelAvatar(
            channel: channel,
            borderRadius: BorderRadius.circular(32),
            selected: selected,
            constraints: const BoxConstraints.tightFor(
              width: 64,
              height: 64,
            ),
            onTap: () => _getChannelTap(context),
          ),
          const SizedBox(height: 7),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: StreamChannel(
              channel: channel,
              child: StreamChannelName(
                channel: channel,
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueryProgressIndicator(
    context,
    ChannelsBlocState channelsProvider,
  ) =>
      BetterStreamBuilder<bool>(
        stream: channelsProvider.queryChannelsLoading,
        initialData: false,
        errorBuilder: (context, err) {
          final theme = StreamChatTheme.of(context);
          return ColoredBox(
            color: theme.colorTheme.textLowEmphasis.withOpacity(0.9),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                context.translations.loadingChannelsError,
                style: theme.textTheme.body.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          );
        },
        builder: (context, showLoading) {
          if (!showLoading) return const Offstage();
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        },
      );

  Widget _separatorBuilder(context, i) {
    final effect = StreamChatTheme.of(context).colorTheme.borderBottom;

    return Container(
      height: 1,
      color: effect.color!.withOpacity(effect.alpha ?? 1.0),
    );
  }
}

/// Class for slidable action
class SwipeAction {
  /// Constructor for creating [SwipeAction]
  SwipeAction({
    this.color,
    required this.iconWidget,
    this.onTap,
  });

  /// Background color of action
  Color? color;

  /// Widget to display as icon
  Widget iconWidget;

  /// Callback when icon is tapped
  ChannelInfoCallback? onTap;
}
