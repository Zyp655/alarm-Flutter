import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/update_user_profile_usecase.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final GetUserProfileUseCase getUserProfile;
  final UpdateUserProfileUseCase updateUserProfile;

  UserBloc({required this.getUserProfile, required this.updateUserProfile})
    : super(UserInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    final result = await getUserProfile(event.userId);
    result.fold(
      (failure) => emit(UserError(failure.message)),
      (user) => emit(UserProfileLoaded(user)),
    );
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    final result = await updateUserProfile(event.user);
    result.fold((failure) => emit(UserError(failure.message)), (_) {
      emit(const UserUpdateSuccess("Cập nhật thành công"));
      add(LoadUserProfile(event.user.id));
    });
  }
}
