import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/multiplayer/multiplayer_bloc.dart';
import '../bloc/multiplayer/multiplayer_event.dart';
import '../bloc/multiplayer/multiplayer_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class MultiplayerGamePage extends StatefulWidget {
  const MultiplayerGamePage({super.key});

  @override
  State<MultiplayerGamePage> createState() => _MultiplayerGamePageState();
}

class _MultiplayerGamePageState extends State<MultiplayerGamePage> {
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess && authState.user != null) {
      _currentUserId = authState.user!.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Challenge'),
        automaticallyImplyLeading: false,
      ),
      body: BlocConsumer<MultiplayerBloc, MultiplayerState>(
        listener: (context, state) {
          if (state is MultiplayerError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is MultiplayerGameStarted) {
            return _buildGameView(state);
          } else if (state is MultiplayerResult) {
            return _buildResultView(state);
          } else if (state is MultiplayerLobby) {
            return const Center(child: Text("Waiting for game start..."));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildGameView(MultiplayerGameStarted state) {
    final question = state.question;
    debugPrint('DEBUG: Question data: $question');
    final optionsList = question['options'] as List?;
    final options = optionsList?.map((e) => e.toString()).toList() ?? [];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LinearProgressIndicator(value: state.timeLeft / 30),
          const SizedBox(height: 10),
          Text(
            'Question ${state.questionIndex + 1}/${state.totalQuestions}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            question['question'] ?? '',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ...options.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: ElevatedButton(
                onPressed: () {
                  context.read<MultiplayerBloc>().add(
                    SubmitAnswerEvent(
                      roomCode: state.roomCode,
                      questionIndex: state.questionIndex,
                      answerIndex: entry.key,
                      userId: _currentUserId ?? 0,
                    ),
                  );
                },
                child: Text(entry.value),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildResultView(MultiplayerResult state) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          'Game Over',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: state.leaderboard.length,
            itemBuilder: (context, index) {
              final player = state.leaderboard[index];
              return ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(player['name'] ?? 'Player'),
                trailing: Text('${player['score']} pts'),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Back to Lobby'),
          ),
        ),
      ],
    );
  }
}
