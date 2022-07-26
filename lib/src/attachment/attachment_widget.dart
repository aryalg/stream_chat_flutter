import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// Enum for identifying type of attachment
enum AttachmentSource {
  /// Attachment is attached
  local,

  /// Attachment is uploaded
  network;

  /// The [when] method is the equivalent to pattern matching.
  /// Its prototype depends on the AttachmentSource defined.
  T when<T>({
    required T Function() local,
    required T Function() network,
  }) {
    switch (this) {
      case AttachmentSource.local:
        return local();
      case AttachmentSource.network:
        return network();
    }
  }
}

/// {@macro attachment_widget}
@Deprecated("Use 'StreamAttachmentWidget' instead")
typedef AttachmentWidget = StreamAttachmentWidget;

/// {@template attachment_widget}
/// Abstract class for deriving attachment types
/// {@endtemplate}
abstract class StreamAttachmentWidget extends StatelessWidget {
  /// Constructor for creating attachment widget
  const StreamAttachmentWidget({
    super.key,
    required this.message,
    required this.attachment,
    this.size,
    AttachmentSource? source,
  }) : _source = source;

  /// Size of attachments
  final Size? size;
  final AttachmentSource? _source;

  /// Message which attachment is attached to
  final Message message;

  /// Attachment to display
  final Attachment attachment;

  /// Getter for source of attachment
  AttachmentSource get source =>
      _source ??
      (attachment.file != null
          ? AttachmentSource.local
          : AttachmentSource.network);
}

/// Widget for building in case of error
class AttachmentError extends StatelessWidget {
  /// Constructor for creating AttachmentError
  const AttachmentError({
    super.key,
    this.size,
  });

  /// Size of error
  final Size? size;

  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          width: size?.width,
          height: size?.height,
          color: StreamChatTheme.of(context)
              .colorTheme
              .accentError
              .withOpacity(0.1),
          child: Center(
            child: Icon(
              Icons.error_outline,
              color: StreamChatTheme.of(context).colorTheme.textHighEmphasis,
            ),
          ),
        ),
      );
}
