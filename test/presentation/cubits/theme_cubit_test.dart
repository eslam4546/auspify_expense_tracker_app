import 'package:bloc_test/bloc_test.dart';
import 'package:expense_tracker/data/datasources/expense_local_data_source.dart';
import 'package:expense_tracker/presentation/cubits/theme/theme_cubit.dart';
import 'package:expense_tracker/presentation/cubits/theme/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockExpenseLocalDataSource extends Mock
    implements ExpenseLocalDataSource {}

void main() {
  late MockExpenseLocalDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockExpenseLocalDataSource();
  });

  group('ThemeCubit', () {
    test('initial state loads persisted theme (light)', () {
      when(() => mockDataSource.getThemeMode()).thenReturn(false);
      final cubit = ThemeCubit(localDataSource: mockDataSource);

      expect(cubit.state.themeMode, equals(ThemeMode.light));
      verify(() => mockDataSource.getThemeMode()).called(1);
    });

    test('initial state loads persisted theme (dark)', () {
      when(() => mockDataSource.getThemeMode()).thenReturn(true);
      final cubit = ThemeCubit(localDataSource: mockDataSource);

      expect(cubit.state.themeMode, equals(ThemeMode.dark));
      verify(() => mockDataSource.getThemeMode()).called(1);
    });

    blocTest<ThemeCubit, ThemeState>(
      'toggleTheme switches light to dark and calls datasource',
      build: () {
        when(() => mockDataSource.getThemeMode()).thenReturn(false);
        when(() => mockDataSource.setThemeMode(true)).thenAnswer((_) async {});
        return ThemeCubit(localDataSource: mockDataSource);
      },
      act: (cubit) => cubit.toggleTheme(),
      expect: () => [const ThemeState(themeMode: ThemeMode.dark)],
      verify: (_) {
        verify(() => mockDataSource.setThemeMode(true)).called(1);
      },
    );
  });
}
