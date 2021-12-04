import 'dart:convert';
import 'dart:io';

class GitApi {
  Future<Process> gitRequester(arguments) async {
    return await Process.start('git', arguments,
        workingDirectory: "fake_commit");
  }
  Future<Directory> _createWorkingDirectory() async {
    return Directory('fake_commit').create();
  }

  void checkGitAvailability(
      {required Function(String userName, String userEmail) onComplete,
        Function(int exitCode)? onExit,
        Function(String error)? onError}) async {
    try {
      await _createWorkingDirectory();
      var gitProcess = await gitRequester(['config', '--get', 'user.name']);
      String userProcessOutput = '';
      await gitProcess.stdout.transform(utf8.decoder).forEach((element) {
        userProcessOutput += element;
      });
      var exCodeUserProcess = await gitProcess.exitCode;
      gitProcess = await gitRequester(['config', '--get', 'user.email']);
      String emailProcessOutput = '';
      await gitProcess.stdout.transform(utf8.decoder).forEach((element) {
        emailProcessOutput += element;
      });
      onComplete(userProcessOutput, emailProcessOutput);
      var exCodeEmailProcess = await gitProcess.exitCode;
      if (exCodeUserProcess == exCodeEmailProcess) {
        onExit!(exCodeUserProcess);
      } else if (exCodeEmailProcess > exCodeUserProcess) {
        onExit!(exCodeUserProcess);
      } else {
        onExit!(exCodeEmailProcess);
      }
    } catch (e) {
      onExit!(-1);
      onError!(e.toString());
    }
  }
}

class FileStorage {
  Future<String> get _gitPath async {
    Directory current = Directory.current;
    return current.path;
  }

  Future<File> get _readmeFile async {
    final path = await _gitPath;
    return File('$path/fake_commit/readme.md');
  }

  Future<File> get _gitIgnoreFile async {
    final path = await _gitPath;
    return File('$path/fake_commit/.gitignore');
  }

  Future<File> get _commitFile async {
    final path = await _gitPath;
    return File('$path/fake_commit/fake_code.txt');
  }

  Future<File> writeReadme() async {
    final file = await _readmeFile;
    return file.writeAsString("d");
  }

  Future<File> writeGitIgnore() async {
    final file = await _gitIgnoreFile;
    return file.writeAsString("*\n!.gitignore\n!readme.md\n!fake_code.txt");
  }

  Future<File> writeCommit(String fileText) async {
    final file = await _commitFile;
    return file.writeAsString(fileText);
  }
}
