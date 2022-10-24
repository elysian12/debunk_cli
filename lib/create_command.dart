import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart' as dcli;
import 'package:mason/mason.dart';

import 'package:http/http.dart' as http;

class CreateCommand extends Command {
  @override
  String get description => 'create a flutter project with bloc architecture';

  @override
  String get name => 'create';

  @override
  Future run() async {
    genearteFlutterProject(argResults!.arguments.first);
  }

  void generateMason(String projectName) async {
    final brick = Brick.git(
      const GitPath(
        'https://github.com/elysian12/flutter_template_brick',
        path: 'flutter_template',
      ),
    );
    final generator = await MasonGenerator.fromBrick(brick);
    final target = DirectoryGeneratorTarget(Directory('$projectName/lib'));
    await generator.generate(target, vars: <String, dynamic>{
      "colors": "colors",
      "textStyle": "text_style",
      "theme": "theme",
      "helper": "helper",
      "helpers": [
        {"name": "Helper"},
        {"name": "IconHelper"},
        {"name": "AssetHelper"},
        {"name": "ImageHelper"}
      ],
      "home": "home",
      "router": "router",
      "main": "main"
    });
  }

  void generateGithubActionMason(String projectName) async {
    final brick = Brick.git(
      const GitPath(
        'https://github.com/elysian12/flutter_template_brick',
        path: 'github_action',
      ),
    );
    final generator = await MasonGenerator.fromBrick(brick);
    final target = DirectoryGeneratorTarget(Directory('$projectName/'));
    await generator.generate(target, vars: <String, dynamic>{
      "project": projectName,
    });
  }

  void genearteFlutterProject(String name) async {
    print('''
# ---------------------------------
# 🚀 Creating ${dcli.orange('Flutter')}💙 project
# ---------------------------------
''');
    await Process.run('flutter', ['create', name]);

    await File('$name/lib/main.dart').delete();

    await installPackages('flutter_screenutil', name);
    await installPackages('flutter_bloc', name);
    await installPackages('equatable', name);

    print('''
# ---------------------------------
# 🚀 Generating ${dcli.blue('Outshade')}💙 template
# ---------------------------------
''');

    generateMason(name);

    await Future.delayed(Duration(seconds: 2));

    print('''
# ---------------------------------
# 🚀 Setting Up the ${dcli.yellow('Github CI/CD')} ⛓
# ---------------------------------
''');
    generateGithubActionMason(name);

    print('''
\n
${dcli.green('All done! ✅')}
In order to run your application, type:

\$ cd $name
\$ flutter run

Your application code is in $name/lib/main.dart.
''');
  }

  Future<void> installPackages(String packageName, String project) async {
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
        final pubspec = File('$project/pubspec.yaml').readAsStringSync();

        final updatedPubspec = pubspec.replaceFirst(
            'dependencies:', 'dependencies:\n  $packageName: ^$version');

        File('$project/pubspec.yaml').writeAsStringSync(updatedPubspec);
      }
    } on HttpException catch (e) {
      print(e.message);
      exit(1);
    }
  }
}
