import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';

import 'package:http/http.dart' as http;

class InstallCommand extends Command {
  @override
  String get description => 'Adds a package to the project';

  @override
  String get name => 'install';

  @override
  Future run() async {
    installPackages(argResults!.arguments.first);
  }

  void installPackages(String packageName) async {
    final url = Uri.parse('https://pub.dev/api/packages/$packageName');

    try {
      var response = await http.get(url);

      if (response.statusCode == HttpStatus.notFound) {
        print(jsonDecode(response.body)['message']);
        exit(1);
      } else {
        // Fetch the version
        var version = jsonDecode(response.body)['latest']['version'];

        //load the pubspec file
        final pubspec = File('pubspec.yaml').readAsStringSync();

        final updatedPubspec = pubspec.replaceFirst(
            'dependencies:\n', 'dependencies:\n \n  $packageName: ^$version\n');

        File('pubspec.yaml').writeAsStringSync(updatedPubspec);
      }
    } on HttpException catch (e) {
      print(e.message);
      exit(1);
    }
  }
}
