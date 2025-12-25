import 'package:flutter_riverpod/legacy.dart';
import 'package:nexus_frontend/models/userModel.dart';
import 'package:nexus_frontend/repository/aiRepository.dart';
import 'package:nexus_frontend/repository/authRepository.dart';

class UserController extends StateNotifier<UserState> {
  final AuthRepository authRepository;
  final AIRepository aiRepository;

  UserController(this.authRepository, this.aiRepository)
    : super(UserState(currentUser: null, aiInsight: ""));

  Future<void> loadUser() async {
    final user = await authRepository.getCurrentUser();
    state = state.copyWith(user, null);
  }

  Future<void> loadAIInsight() async
  {
    final aiInsight = await aiRepository.getAIInsight();
    state = state.copyWith(null, aiInsight);
  }

  void clear() {
    state = state.copyWith(null, null);
  }
}

class UserState {
  final UserModel? currentUser;
  final String aiInsight;

  UserState({required this.currentUser, required this.aiInsight});

  UserState copyWith(UserModel? currentUser, String? aiInsight) {
    return UserState(
      currentUser: currentUser,
      aiInsight: aiInsight ?? this.aiInsight,
    );
  }
}

final userControllerProvider = StateNotifierProvider<UserController, UserState>(
  (ref) {
    return UserController(ref.read(authRespositoryProvider), ref.read(aiRepositoryProvider));
  },
);
