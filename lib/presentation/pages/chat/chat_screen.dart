import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/chat/chat_bloc.dart';
import '../../blocs/chat/chat_event.dart';
import '../../blocs/chat/chat_state.dart';
import '../../widgets/chat_message_widget.dart';

class ChatScreen extends StatefulWidget {
  final String cityName;

  const ChatScreen({Key? key, required this.cityName}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  late final ChatBloc _chatBloc;

  @override
  void initState() {
    super.initState();
    _chatBloc = context.read<ChatBloc>();
    _chatBloc.add(ConnectToCityEvent(widget.cityName));
    
    // Listen to text changes to rebuild send button
    _messageController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    // Use the stored reference instead of context.read()
    _chatBloc.add(DisconnectEvent());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.cityName),
            BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatConnected) {
                  return Text(
                    'Connected',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  );
                } else if (state is ChatConnecting) {
                  return Text(
                    'Connecting...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  );
                } else {
                  return Text(
                    'Disconnected',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatConnecting) {
                  return _buildConnectingState();
                } else if (state is ChatConnected) {
                  return _buildChatMessages(state.messages);
                } else if (state is ChatError) {
                  return _buildErrorState(state.message);
                } else if (state is CachedMessagesLoaded) {
                  return _buildCachedMessages(state.messages);
                }
                return _buildDisconnectedState();
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildConnectingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Connecting to ${widget.cityName} chat...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessages(List messages) {
    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16),
            Text(
              'No messages yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            SizedBox(height: 8),
            Text(
              'Be the first to send a message!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
            ),
          ],
        ),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        return ChatMessageWidget(message: messages[index]);
      },
    );
  }

  Widget _buildCachedMessages(List messages) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12),
          color: Colors.orange.shade100,
          child: Row(
            children: [
              Icon(Icons.offline_bolt, color: Colors.orange.shade800, size: 16),
              SizedBox(width: 8),
              Text(
                'Showing cached messages - Reconnecting...',
                style: TextStyle(
                  color: Colors.orange.shade800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Expanded(child: _buildChatMessages(messages)),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red.shade400,
          ),
          SizedBox(height: 16),
          Text(
            'Connection Error',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.red.shade600,
                ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              _chatBloc.add(ConnectToCityEvent(widget.cityName));
            },
            child: Text('Retry Connection'),
          ),
        ],
      ),
    );
  }

  Widget _buildDisconnectedState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            'Disconnected',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          SizedBox(height: 8),
          Text(
            'Connect to start chatting',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              _chatBloc.add(ConnectToCityEvent(widget.cityName));
            },
            child: Text('Connect'),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, chatState) {
          return BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              final isConnected = chatState is ChatConnected;
              final username = authState is AuthAuthenticated
                  ? authState.user.username
                  : 'Anonymous';

              return Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      enabled: isConnected,
                      decoration: InputDecoration(
                        hintText: isConnected
                            ? 'Type a message...'
                            : 'Not connected',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: _canSendMessage(isConnected) ? (_) => _sendMessage(username) : null,
                      maxLines: null,
                      maxLength: 500,
                      buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
                        return null; // Hide character counter
                      },
                    ),
                  ),
                  SizedBox(width: 12),
                  FloatingActionButton(
                    onPressed: _canSendMessage(isConnected)
                        ? () => _sendMessage(username)
                        : null,
                    mini: true,
                    backgroundColor: _canSendMessage(isConnected)
                        ? Colors.blue
                        : Colors.grey.shade300,
                    child: Icon(
                      Icons.send,
                      color: _canSendMessage(isConnected)
                          ? Colors.white
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  bool _canSendMessage(bool isConnected) {
    return isConnected && _messageController.text.trim().isNotEmpty;
  }

  void _sendMessage(String username) {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      _chatBloc.add(
            SendMessageEvent(message, username, widget.cityName),
          );
      _messageController.clear();
      // No need to call setState here since addListener will handle it
    }
  }
}