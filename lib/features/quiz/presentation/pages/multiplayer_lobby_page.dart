import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart' as di;
import '../bloc/multiplayer/multiplayer_bloc.dart';
import '../bloc/multiplayer/multiplayer_event.dart';
import '../bloc/multiplayer/multiplayer_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import 'multiplayer_game_page.dart';
import 'generate_quiz_page.dart';
import '../../../../core/theme/app_colors.dart';

class MultiplayerLobbyPage extends StatelessWidget {
  const MultiplayerLobbyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<MultiplayerBloc>(),
      child: const MultiplayerLobbyView(),
    );
  }
}

class MultiplayerLobbyView extends StatefulWidget {
  const MultiplayerLobbyView({super.key});

  @override
  State<MultiplayerLobbyView> createState() => _MultiplayerLobbyViewState();
}

class _MultiplayerLobbyViewState extends State<MultiplayerLobbyView> {
  final _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess && authState.user != null) {
      context.read<MultiplayerBloc>().add(LoadQuizzes(authState.user!.id));
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _createRoom(BuildContext context) {
    final state = context.read<MultiplayerBloc>().state;
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthSuccess || authState.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
                    content: Text('Vui lòng đăng nhập để tạo phòng')),
      );
      return;
    }
    final user = authState.user!;

    if (state is QuizzesLoaded && state.quizzes.isNotEmpty) {
      final firstQuizId = state.quizzes.first['id'];
      context.read<MultiplayerBloc>().add(
        CreateRoomEvent(firstQuizId, user.id, user.fullName ?? user.email),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Không tìm thấy bài trắc nghiệm nào. Hãy tạo mới!',
          ),
          action: SnackBarAction(
            label: 'Tạo ngay',
            textColor: Colors.yellow,
            onPressed: () async {
              final quizId = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const GenerateQuizPage(isForMultiplayer: true),
                ),
              );

              if (quizId != null && context.mounted) {
                context.read<MultiplayerBloc>().add(
                  CreateRoomEvent(
                    quizId as int,
                    user.id,
                    user.fullName ?? user.email,
                  ),
                );
              }
            },
          ),
        ),
      );
      context.read<MultiplayerBloc>().add(LoadQuizzes(user.id));
    }
  }

  void _joinRoom(BuildContext context) {
    if (_codeController.text.length != 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(
                    content: Text('Mã phòng phải có 6 ký tự')));
      return;
    }
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess && authState.user != null) {
      final user = authState.user!;
      context.read<MultiplayerBloc>().add(
        ConnectToServer(
          _codeController.text,
          user.id,
          user.fullName ?? user.email,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
                    content: Text('Vui lòng đăng nhập để tham gia phòng')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? AppColors.darkSurface : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : Colors.grey[100],
      appBar: AppBar(
        title: const Text('Chơi Multiplayer'),
        centerTitle: true,
        backgroundColor: isDarkMode
            ? AppColors.darkSurface
            : Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocConsumer<MultiplayerBloc, MultiplayerState>(
        listener: (context, state) {
          if (state is MultiplayerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is MultiplayerGameStarted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<MultiplayerBloc>(),
                  child: const MultiplayerGamePage(),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is MultiplayerLobby) {
            return _buildWaitingRoom(context, state, isDarkMode);
          }

          final isLoading = state is MultiplayerLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildCreateRoomCard(context, cardColor, textColor, isLoading),
                const SizedBox(height: 16),
                _buildJoinRoomCard(
                  context,
                  cardColor,
                  textColor,
                  isDarkMode,
                  isLoading,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple, Colors.deepPurple.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.groups, size: 64, color: Colors.white),
          const SizedBox(height: 16),
          const Text(
            'Quiz Multiplayer',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thi đấu trực tiếp với bạn bè',
            style: TextStyle(fontSize: 14, color: Colors.white.withAlpha(200)),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateRoomCard(
    BuildContext context,
    Color cardColor,
    Color textColor,
    bool isLoading,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.add_circle, color: AppColors.secondary, size: 28),
              const SizedBox(width: 12),
              Text(
                'Tạo phòng mới',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Tạo một phòng chơi và mời bạn bè tham gia',
            style: TextStyle(color: textColor.withAlpha(180)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : () => _createRoom(context),
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.play_arrow),
              label: Text(isLoading ? 'Đang xử lý...' : 'Tạo phòng'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final quizId = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const GenerateQuizPage(isForMultiplayer: true),
                  ),
                );

                if (quizId != null && context.mounted) {
                  final authState = context.read<AuthBloc>().state;
                  if (authState is AuthSuccess && authState.user != null) {
                    final user = authState.user!;
                    context.read<MultiplayerBloc>().add(
                      CreateRoomEvent(
                        quizId as int,
                        user.id,
                        user.fullName ?? user.email,
                      ),
                    );
                  }
                }
              },
              icon: Icon(Icons.auto_awesome, color: AppColors.secondary),
              label: const Text(
                'Tạo Quiz AI mới',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: AppColors.secondary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinRoomCard(
    BuildContext context,
    Color cardColor,
    Color textColor,
    bool isDarkMode,
    bool isLoading,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.login, color: AppColors.warning, size: 28),
              const SizedBox(width: 12),
              Text(
                'Tham gia phòng',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Nhập mã phòng để tham gia',
            style: TextStyle(color: textColor.withAlpha(180)),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _codeController,
            textCapitalization: TextCapitalization.characters,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
            ),
            decoration: InputDecoration(
              hintText: 'XXXXXX',
              counterText: '',
              filled: true,
              fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
              UpperCaseTextFormatter(),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : () => _joinRoom(context),
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.arrow_forward),
              label: Text(isLoading ? 'Đang tham gia...' : 'Tham gia'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingRoom(
    BuildContext context,
    MultiplayerLobby state,
    bool isDarkMode,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Room Code: ${state.roomCode}",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            "Players: ${state.players.length}",
            style: const TextStyle(fontSize: 18),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: state.players.length,
              itemBuilder: (context, index) {
                final player = state.players[index];
                return ListTile(
                  title: Text(player['name'] ?? 'Player'),
                  leading: Icon(Icons.person),
                );
              },
            ),
          ),
          if (state.isHost)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  context.read<MultiplayerBloc>().add(
                    StartGameEvent(state.roomCode),
                  );
                },
                child: const Text("Start Game"),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Waiting for host to start..."),
            ),
        ],
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
