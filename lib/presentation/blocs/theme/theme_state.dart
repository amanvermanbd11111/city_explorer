import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class ThemeState extends Equatable {
  const ThemeState();

  @override
  List<Object?> get props => [];
}

class ThemeInitial extends ThemeState {}

class ThemeLoaded extends ThemeState {
  final bool isDarkMode;
  final ThemeData themeData;

  const ThemeLoaded({
    required this.isDarkMode,
    required this.themeData,
  });

  @override
  List<Object?> get props => [isDarkMode, themeData];
}