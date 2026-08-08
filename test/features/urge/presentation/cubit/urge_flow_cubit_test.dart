import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sanad/core/errors/failures.dart';
import 'package:sanad/core/usecase/usecase.dart';
import 'package:sanad/features/urge/domain/entities/behavior.dart';
import 'package:sanad/features/urge/domain/entities/urge_entry.dart';
import 'package:sanad/features/urge/domain/usecases/clear_active_urge.dart';
import 'package:sanad/features/urge/domain/usecases/get_active_urge.dart';
import 'package:sanad/features/urge/domain/usecases/get_behaviors.dart';
import 'package:sanad/features/urge/domain/usecases/save_urge.dart';
import 'package:sanad/features/urge/presentation/cubit/urge_flow_cubit.dart';
import 'package:sanad/features/urge/presentation/cubit/urge_flow_state.dart';

class FakeGetActiveUrge implements GetActiveUrge {
  Either<Failure, UrgeEntry?> result = const Right(null);
  @override
  Future<Either<Failure, UrgeEntry?>> call(NoParams params) async => result;
  @override
  get repository => throw UnimplementedError();
}

class FakeSaveUrge implements SaveUrge {
  @override
  Future<Either<Failure, void>> call(UrgeEntry params) async => const Right(null);
  @override
  get repository => throw UnimplementedError();
}

class FakeClearActiveUrge implements ClearActiveUrge {
  @override
  Future<Either<Failure, void>> call(NoParams params) async => const Right(null);
  @override
  get repository => throw UnimplementedError();
}

class FakeGetBehaviors implements GetBehaviors {
  Either<Failure, List<Behavior>> result = const Right([]);
  @override
  Future<Either<Failure, List<Behavior>>> call(NoParams params) async => result;
  @override
  get repository => throw UnimplementedError();
}

void main() {
  late UrgeFlowCubit cubit;
  late FakeGetActiveUrge fakeGetActiveUrge;
  late FakeSaveUrge fakeSaveUrge;
  late FakeClearActiveUrge fakeClearActiveUrge;
  late FakeGetBehaviors fakeGetBehaviors;

  final tBehavior = Behavior(
    id: 'b1',
    name: 'Test Behavior',
    iconCode: 0,
    colorHex: 'FFFFFF',
    whyStatement: 'Test',
    startDate: DateTime(2023),
    createdAt: DateTime(2023),
    isArchived: false,
  );

  setUp(() {
    fakeGetActiveUrge = FakeGetActiveUrge();
    fakeSaveUrge = FakeSaveUrge();
    fakeClearActiveUrge = FakeClearActiveUrge();
    fakeGetBehaviors = FakeGetBehaviors();
    
    cubit = UrgeFlowCubit(
      getActiveUrge: fakeGetActiveUrge,
      saveUrge: fakeSaveUrge,
      clearActiveUrge: fakeClearActiveUrge,
      getBehaviors: fakeGetBehaviors,
    );
  });

  group('initializeFlow', () {
    test('emits logging state with new urge when no active urge exists', () async {
      fakeGetActiveUrge.result = const Right(null);
      fakeGetBehaviors.result = Right([tBehavior]);

      await cubit.initializeFlow();

      expect(cubit.state.status, UrgeFlowStatus.logging);
      expect(cubit.state.activeUrge, isNotNull);
      expect(cubit.state.selectedBehavior, tBehavior);
    });

    test('emits failure when no behaviors exist', () async {
      fakeGetActiveUrge.result = const Right(null);
      fakeGetBehaviors.result = const Right([]);

      await cubit.initializeFlow();

      expect(cubit.state.status, UrgeFlowStatus.failure);
      expect(cubit.state.errorMessage, 'No behaviors defined. Please add one first.');
    });
  });
}
