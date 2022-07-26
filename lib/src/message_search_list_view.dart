// ignore: lines_longer_than_80_chars
// ignore_for_file: deprecated_member_use_from_same_package, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/src/extension.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// Callback called when tapping on a user
typedef MessageSearchItemTapCallback = void Function(GetMessageResponse);

/// Builder used to create a custom [ListUserItem] from a [User]
typedef MessageSearchItemBuilder = Widget Function(
  BuildContext,
  GetMessageResponse,
);

/// Builder used when [MessageSearchListView] is empty
typedef EmptyMessageSearchBuilder = Widget Function(
  BuildContext context,
  String searchQuery,
);

/// {@template message_search_list_view}
/// It shows the list of searched messages.
///
/// ```dart
/// class MessageSearchPage extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       body: MessageSearchListView(
///         messageQuery: _channelQuery,
///         filters: {
///           'members': {
///             r'$in': [user.id]
///           }
///         },
///         limit: 20,
///       ),
///     );
///   }
/// }
/// ```
///
///
/// Make sure to have a [MessageSearchBloc] ancestor in order to provide the
/// information about the messages.
/// The widget uses a [ListView.separated] to render the list of messages.
///
/// The widget components render the ui based on the first ancestor of type
/// [StreamChatTheme].
/// Modify it to change the widget appearance.
/// {@endtemplate}
@Deprecated("Use 'StreamMessageSearchListView' instead")
class MessageSearchListView extends StatefulWidget {
  /// Instantiate a new MessageSearchListView
  @Deprecated("Use 'StreamMessageSearchListView' instead")
  const MessageSearchListView({
    super.key,
    required this.filters,
    this.messageQuery,
    this.sortOptions,
    this.limit = 30,
    this.messageFilters,
    this.separatorBuilder,
    this.itemBuilder,
    this.onItemTap,
    this.showResultCount = true,
    this.pullToRefresh = true,
    this.showErrorTile = false,
    this.emptyBuilder,
    this.errorBuilder,
    this.loadingBuilder,
    this.childBuilder,
    this.messageSearchListController,
  });

  /// Message String to search on
  final String? messageQuery;

  /// The query filters to use.
  /// You can query on any of the custom fields you've defined on the [Channel].
  /// You can also filter other built-in channel fields.
  final Filter filters;

  /// The sorting used for the channels matching the filters.
  /// Sorting is based on field and direction, multiple sorting options
  /// can be provided.
  /// You can sort based on last_updated, last_message_at, updated_at,
  /// created_at or member_count.
  /// Direction can be ascending or descending.
  final List<SortOption>? sortOptions;

  /// The amount of messages requested per API call.
  final int limit;

  /// The message query filters to use.
  /// You can query on any of the custom fields you've defined on the [Channel].
  /// You can also filter other built-in channel fields.
  final Filter? messageFilters;

  /// Builder used to create a custom item preview
  final MessageSearchItemBuilder? itemBuilder;

  /// Function called when tapping on a [MessageSearchItem]
  final MessageSearchItemTapCallback? onItemTap;

  /// Builder used to create a custom item separator
  final IndexedWidgetBuilder? separatorBuilder;

  /// Set it to false to hide total results text
  final bool showResultCount;

  /// Set it to false to disable the pull-to-refresh widget
  final bool pullToRefresh;

  /// Show error tile on top
  final bool showErrorTile;

  /// The builder that is used when the search messages are fetched
  final Widget Function(List<GetMessageResponse>)? childBuilder;

  /// The builder used when the channel list is empty.
  final WidgetBuilder? emptyBuilder;

  /// The builder that will be used in case of error
  final ErrorBuilder? errorBuilder;

  /// The builder that will be used in case of loading
  final WidgetBuilder? loadingBuilder;

  /// A [MessageSearchListController] allows reloading and pagination.
  /// Use [MessageSearchListController.loadData] and
  /// [MessageSearchListController.paginateData] respectively for reloading and
  /// pagination.
  final MessageSearchListController? messageSearchListController;

  @override
  _MessageSearchListViewState createState() => _MessageSearchListViewState();
}

class _MessageSearchListViewState extends State<MessageSearchListView> {
  late final _defaultController = MessageSearchListController();

  MessageSearchListController get _messageSearchListController =>
      widget.messageSearchListController ?? _defaultController;

  @override
  Widget build(BuildContext context) {
    final messageSearchListCore = MessageSearchListCore(
      filters: widget.filters,
      sortOptions: widget.sortOptions,
      messageQuery: widget.messageQuery,
      limit: widget.limit,
      messageFilters: widget.messageFilters,
      messageSearchListController: _messageSearchListController,
      emptyBuilder: widget.emptyBuilder ??
          (context) => LayoutBuilder(
                builder: (context, viewportConstraints) =>
                    SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: viewportConstraints.maxHeight,
                    ),
                    child: Center(
                      child: Text(context.translations.emptyMessagesText),
                    ),
                  ),
                ),
              ),
      errorBuilder: widget.errorBuilder ??
          (BuildContext context, dynamic error) {
            if (error is Error) {
              print(error.stackTrace);
            }
            return StreamInfoTile(
              showMessage: widget.showErrorTile,
              tileAnchor: Alignment.topCenter,
              childAnchor: Alignment.topCenter,
              message: context.translations.genericErrorText,
              child: Container(),
            );
          },
      loadingBuilder: widget.loadingBuilder ??
          (context) => LayoutBuilder(
                builder: (context, viewportConstraints) =>
                    SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: viewportConstraints.maxHeight,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),
      childBuilder: widget.childBuilder ?? _buildListView,
    );

    final backgroundColor =
        StreamMessageSearchListViewTheme.of(context).backgroundColor;

    if (backgroundColor != null) {
      return ColoredBox(
        color: backgroundColor,
        child: messageSearchListCore,
      );
    }

    return messageSearchListCore;
  }

  Widget _separatorBuilder(BuildContext context, int index) => Container(
        height: 1,
        color: StreamChatTheme.of(context).colorTheme.borders,
      );

  Widget _listItemBuilder(
    BuildContext context,
    GetMessageResponse getMessageResponse,
  ) {
    if (widget.itemBuilder != null) {
      return widget.itemBuilder!(context, getMessageResponse);
    }
    return MessageSearchItem(
      getMessageResponse: getMessageResponse,
      onTap: () => widget.onItemTap!(getMessageResponse),
    );
  }

  Widget _buildQueryProgressIndicator(context) {
    final messageSearchBloc = MessageSearchBloc.of(context);

    return StreamBuilder<bool>(
      stream: messageSearchBloc.queryMessagesLoading,
      initialData: false,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ColoredBox(
            color: StreamChatTheme.of(context)
                .colorTheme
                .accentError
                .withOpacity(0.2),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(context.translations.loadingMessagesError),
              ),
            ),
          );
        }
        return Container(
          height: 100,
          padding: const EdgeInsets.all(32),
          child: Center(
            child: snapshot.data!
                ? const CircularProgressIndicator()
                : Container(),
          ),
        );
      },
    );
  }

  Widget _buildListView(List<GetMessageResponse> data) {
    final items = data;

    Widget child = ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: items.isNotEmpty ? items.length + 1 : items.length,
      separatorBuilder: (_, index) {
        if (widget.separatorBuilder != null) {
          return widget.separatorBuilder!(context, index);
        }
        return _separatorBuilder(context, index);
      },
      itemBuilder: (context, index) {
        if (index < items.length) {
          return _listItemBuilder(context, items[index]);
        }
        return _buildQueryProgressIndicator(context);
      },
    );
    if (widget.pullToRefresh) {
      child = RefreshIndicator(
        onRefresh: () => _messageSearchListController.loadData!(),
        child: child,
      );
    }

    child = LazyLoadScrollView(
      onEndOfPage: () => _messageSearchListController.paginateData!(),
      child: child,
    );

    if (widget.showResultCount) {
      final chatThemeData = StreamChatTheme.of(context);
      child = Column(
        children: [
          Container(
            width: double.maxFinite,
            decoration: BoxDecoration(
              gradient: chatThemeData.colorTheme.bgGradient,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 8,
              ),
              child: Text(
                context.translations.resultCountText(items.length),
                style: TextStyle(
                  color: chatThemeData.colorTheme.textLowEmphasis,
                ),
              ),
            ),
          ),
          Expanded(child: child),
        ],
      );
    }
    return child;
  }
}
