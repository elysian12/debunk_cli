import 'package:args/command_runner.dart';
import 'package:debunk/create_command.dart';

import 'package:debunk/install_command.dart';

void main(List<String> args) async {
  final runner = CommandRunner('debunk',
      ' create flutter projects and manage packages in your flutter project')
    ..addCommand(InstallCommand())
    ..addCommand(CreateCommand());

  await runner.run(args);
}
