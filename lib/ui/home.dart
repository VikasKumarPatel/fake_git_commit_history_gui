import 'dart:math';
import 'dart:ui';

import 'package:fake_git_commit_history_gui/git_manager/git_apis.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GitUserConfig extends StatefulWidget {
  GitUserConfig({Key? key}) : super(key: key);
  TextEditingController gitUserNameController = TextEditingController();
  TextEditingController gitEmailController = TextEditingController();

  @override
  _GitUserConfigState createState() => _GitUserConfigState();
}

class _GitUserConfigState extends State<GitUserConfig> {
  GitApi gitApi = GitApi();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final snackBar = SnackBar(
        content: const Text(
            'Loading default git user.name and user.email configurations!'),
        onVisible: () => {
          gitApi.checkGitAvailability(onComplete: (userName, userEmail) {
            widget.gitUserNameController.text = userName;
            widget.gitEmailController.text = userEmail;
            setState(() {});
          }, onExit: (exitCode) {
            ScaffoldMessenger.of(context).dispose;
          })
        },
        duration: Duration.zero,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 10,
                child: TextFormField(
                  maxLength: 45,
                  controller: widget.gitUserNameController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter user.name';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.person),
                    labelText: 'Git User Name',
                    helperText: 'user.name',
                  ),
                ),
              ),
              const SizedBox(width: 30),
              Expanded(
                flex: 10,
                child: TextFormField(
                  maxLength: 45,
                  controller: widget.gitEmailController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter user.email';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    icon: Icon(Icons.person),
                    labelText: 'Git User Email',
                    helperText: 'user.email',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GitCommitConfig extends StatefulWidget {
  const GitCommitConfig({Key? key}) : super(key: key);

  @override
  _GitCommitConfigState createState() => _GitCommitConfigState();
}

class _GitCommitConfigState extends State<GitCommitConfig> {
  TextEditingController gitDateRange = TextEditingController();
  TextEditingController gitMinNoOfCommits = TextEditingController();
  TextEditingController gitMaxNoOfCommits = TextEditingController();
  TextEditingController gitCommitMsg1 = TextEditingController();
  TextEditingController gitCommitMsg2 = TextEditingController();
  DateTime commitStartDate = DateTime.now(), commitEndDate = DateTime.now();
  bool isChecked = false;
  List<bool> checked = [false, false, false, false, false, false, true];
  GitUserConfig gitUserConfig = GitUserConfig();
  List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  var dialogMsg = '';
  double dialogProgress = 0.0;

  Future<bool> validateInputs() async {
    String dialogMsg = '';
    if (gitUserConfig.gitUserNameController.value.text.isEmpty) {
      dialogMsg += 'User name is required\n';
    }
    if (gitUserConfig.gitEmailController.value.text.isEmpty) {
      dialogMsg += 'User Email is required\n';
    }
    if (gitDateRange.value.text.isEmpty) {
      dialogMsg += 'Commit date range is required\n';
    }
    if (gitMinNoOfCommits.value.text.isEmpty) {
      dialogMsg += 'Daily Minimum number of commits is required\n';
    }
    if (gitMaxNoOfCommits.value.text.isEmpty) {
      dialogMsg += 'Daily Minimum number of commits is required\n';
    }
    try {
      if (int.parse(gitMinNoOfCommits.value.text) >
          int.parse(gitMaxNoOfCommits.value.text)) {
        dialogMsg +=
        'Daily minimum number of commits should be smaller or equal to Daily maximum number of commits.\n';
      }
    } catch (e) {
      dialogMsg += 'Invalid minimum or maximum number of commit\n';
    }
    var count = 0;
    for (var i = 0; i < 7; i += 1) {
      if (checked[i]) {
        count++;
      }
    }
    if (count == 7) {
      dialogMsg += "Can't Skip all days of a week\n";
    }
    if (dialogMsg.isNotEmpty) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              scrollable: true,
              title: const Text('Error!'),
              content: Text('Please review following validation\n' + dialogMsg),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          });
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          gitUserConfig,
          const SizedBox(height: 30),
          Row(
            children: [
              SizedBox(
                width: 260,
                child: TextFormField(
                  controller: gitDateRange,
                  readOnly: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter/Select date range';
                    }
                    return null;
                  },
                  onTap: () async {
                    DateTimeRange? gitDate = await showDateRangePicker(
                      context: context,
                      initialEntryMode: DatePickerEntryMode.input,
                      initialDateRange: DateTimeRange(
                        start: DateTime(2019, 01, 01),
                        end: DateTime.now(),
                      ),
                      firstDate: DateTime(2015, 1),
                      lastDate: DateTime.now(),
                      helpText: 'Select Fake commit date range',
                    );
                    if (gitDate?.start != null) {
                      commitStartDate = gitDate!.start;
                      commitEndDate = gitDate.end;
                      gitDateRange.text = gitDate.start.toString().substring(
                          0, gitDate.start.toString().lastIndexOf(' ')) +
                          ' : ' +
                          gitDate.end.toString().substring(
                              0, gitDate.end.toString().lastIndexOf(' '));
                    }
                  },
                  decoration: const InputDecoration(
                    icon: Icon(Icons.date_range),
                    labelText: 'Select Fake commit date range',
                  ),
                ),
              ),
              const SizedBox(width: 70),
              SizedBox(
                width: 200,
                child: TextFormField(
                  controller: gitMinNoOfCommits,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter min. number of commits per day';
                    }
                    return null;
                  },
                  onTap: () async {},
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(2),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  keyboardType:
                  const TextInputType.numberWithOptions(signed: true),
                  decoration: const InputDecoration(
                    icon: Icon(Icons.content_copy_sharp),
                    labelText: 'Min. commits per day',
                  ),
                ),
              ),
              SizedBox(
                width: 200,
                child: TextFormField(
                  controller: gitMaxNoOfCommits,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter max. number of commits per day';
                    }
                    return null;
                  },
                  onTap: () async {},
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(2),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  keyboardType:
                  const TextInputType.numberWithOptions(signed: true),
                  decoration: const InputDecoration(
                    icon: Icon(Icons.content_copy_sharp),
                    labelText: 'Max. commits per day',
                  ),
                ),
              ),
              const SizedBox(
                width: 40,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text('Skip These Days'),
              const SizedBox(
                width: 10,
              ),
              for (var i = 0; i < 7; i += 1)
                Row(
                  children: [
                    Checkbox(
                      onChanged: (value) {
                        setState(() {
                          checked[i] = value!;
                        });
                      },
                      value: checked[i],
                      activeColor: Colors.red,
                    ),
                    Text(
                      daysOfWeek[i],
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 10,
                child: TextFormField(
                  keyboardType: TextInputType.multiline,
                  maxLines: 10,
                  controller: gitCommitMsg1,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter commit message 1';
                    }
                    return null;
                  },
                  onTap: () async {},
                  decoration: const InputDecoration(
                    icon: Icon(Icons.create),
                    labelText: 'Commit Message 1',
                  ),
                ),
              ),
              Expanded(
                flex: 10,
                child: TextFormField(
                  keyboardType: TextInputType.multiline,
                  maxLines: 10,
                  controller: gitCommitMsg2,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter commit message 2';
                    }
                    return null;
                  },
                  onTap: () async {},
                  decoration: const InputDecoration(
                    icon: Icon(Icons.create),
                    labelText: 'Commit Message 2',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  var validationResult = await validateInputs();
                  if (validationResult) {
                    String daysSkipped = '';
                    for (var i = 0; i < 7; i += 1) {
                      if (checked[i]) {
                        daysSkipped += daysOfWeek[i] + ', ';
                      }
                    }
                    if (daysSkipped.isNotEmpty) {
                      daysSkipped += 'Skipped';
                    }
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirm Start Fake Commit?'),
                            content: Text(
                                'Git will be configured for given-\nusername:: ' +
                                    gitUserConfig
                                        .gitUserNameController.value.text +
                                    'Email:: ' +
                                    gitUserConfig
                                        .gitEmailController.value.text +
                                    'Selected Date Range:: ' +
                                    gitDateRange.value.text +
                                    '\nMinimum Commits/Day:: ' +
                                    gitMinNoOfCommits.value.text +
                                    '\nMaximum Commits/Day:: ' +
                                    gitMaxNoOfCommits.value.text +
                                    '\nSkip Days:: ' +
                                    daysSkipped),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('NO'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (_) {
                                        return CommitDialogue(
                                          userEmail: gitUserConfig
                                              .gitEmailController.value.text,
                                          userName: gitUserConfig
                                              .gitUserNameController.value.text,
                                          commitStartDate: commitStartDate,
                                          commitEndDate: commitEndDate,
                                          skippedDays: checked,
                                          commitMsg1: gitCommitMsg1.value.text,
                                          commitMsg2: gitCommitMsg2.value.text,
                                          minCommit: int.parse(
                                              gitMinNoOfCommits.value.text),
                                          maxCommit: int.parse(
                                              gitMaxNoOfCommits.value.text),
                                        );
                                      });
                                },
                                child: const Text('YES'),
                              ),
                            ],
                          );
                        });
                  }
                },
                child: const Text('Generate Fake Commits'),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text('Created With'),
              IconButton(
                icon: const Icon(Icons.favorite),
                color: Colors.red,
                tooltip: 'Give Star on github for this project',
                onPressed: () {},
              ),
              GestureDetector(
                child: const Text(
                  'By @VikasKumarPatel',
                  style: TextStyle(
                      color: Colors.blue, decoration: TextDecoration.underline),
                ),
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CommitDialogue extends StatefulWidget {
  const CommitDialogue(
      {Key? key,
        required this.userName,
        required this.userEmail,
        required this.commitStartDate,
        required this.commitEndDate,
        required this.skippedDays,
        required this.commitMsg1,
        required this.commitMsg2,
        required this.minCommit,
        required this.maxCommit})
      : super(key: key);
  final String userName, userEmail;
  final DateTime commitStartDate, commitEndDate;
  final List<bool> skippedDays;
  final String commitMsg1, commitMsg2;
  final int minCommit, maxCommit;

  @override
  _CommitDialogueState createState() => _CommitDialogueState();
}

class _CommitDialogueState extends State<CommitDialogue> {
  var dialogMsg = '';
  var dialogTitle = 'Setting up fake commit';
  var processMsg = '';
  var totalProcess = 2;
  var completedCProcess = 1;
  double dialogProgress = 0.0;
  GitApi gitApi = GitApi();

  _CommitDialogueState() {
    startFakeCommit();
  }

  void startFakeCommit() async {
    FileStorage fileStorage = FileStorage();
    await fileStorage.writeReadme();
    setState(() {
      dialogProgress = 0.5;
      processMsg = 'Created readme.md file, now generating .gitignore file';
      dialogMsg = 'Please wait...';
    });
    await fileStorage.writeGitIgnore();
    setState(() {
      dialogProgress = 1.0;
      processMsg = 'Created .gitignore file';
      dialogMsg = 'This process may take some time, please wait...';
      dialogTitle = 'Starting fake git commit history';
    });

    try {
      var gitProcess=await gitApi.gitRequester(['init']);
      await gitProcess.exitCode;
      gitProcess.kill();
      gitProcess=await gitApi
          .gitRequester(["config", "--local", "user.name", widget.userName]);
      await gitProcess.exitCode;
      gitProcess.kill();
      gitProcess=await gitApi
          .gitRequester(["config", "--local", "user.email", widget.userEmail]);
      await gitProcess.exitCode;
      gitProcess.kill();
    } catch (e) {
      Navigator.pop(context, true);
      showSnackBarMessage(e.toString());
    }
    Duration totalDuration =
    widget.commitEndDate.difference(widget.commitStartDate);
    totalProcess = totalDuration.inDays;
    String cmtMsg1 =
    widget.commitMsg1 != '' ? widget.commitMsg1 : 'Fake Commit 1';
    String cmtMsg2 =
    widget.commitMsg2 != '' ? widget.commitMsg2 : 'Fake Commit 2';
    DateTime commitDate = widget.commitStartDate;
    var random = Random();

    for (var i = 1; i <= totalProcess; i++) {
      if (widget.skippedDays[commitDate.weekday - 1]) {
        commitDate = commitDate.add(const Duration(days: 1));
        continue;
      }
      var max = (widget.minCommit +
          random.nextInt(widget.maxCommit - widget.minCommit + 1));
      for (var min = widget.minCommit; min <= max; min++) {
        await fileStorage.writeCommit('$i-$min');
        try {
          await gitApi.gitRequester(["add", "."]);
          var tmpDate =
          commitDate.add(Duration(minutes: min, seconds: max - min));
          var gitProcess;
          if (min % 2 == 0) {
            gitProcess=await gitApi.gitRequester(
                ["commit", "--date", tmpDate.toString(), "-m", cmtMsg1]);
          } else {
            gitProcess=await gitApi.gitRequester(
                ["commit", "--date", tmpDate.toString(), "-m", cmtMsg2]);
          }
          await gitProcess.exitCode;
          gitProcess.kill();
          setState(() {
            dialogProgress = i / totalProcess;
            completedCProcess = i;
            processMsg =
                'File change:\n $i-$min on ' + tmpDate.toIso8601String();
          });
        } catch (e) {
          Navigator.pop(context, true);
          showSnackBarMessage(e.toString());
        }
      }
      commitDate = commitDate.add(const Duration(days: 1));
    }
    Navigator.pop(context, true);
    showSnackBarMessage(
        "Fake git history generated successfully in fake_commit directory");
  }

  void showSnackBarMessage(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration.zero,
      action: SnackBarAction(
        label: 'Got it',
        onPressed: () {
          ScaffoldMessenger.of(context).dispose;
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(dialogTitle),
      content: Column(
        children: [
          Text(dialogMsg),
          LinearProgressIndicator(
            value: dialogProgress,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 9,
                child: Text(processMsg),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 2,
                child: Text('$completedCProcess/$totalProcess'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
