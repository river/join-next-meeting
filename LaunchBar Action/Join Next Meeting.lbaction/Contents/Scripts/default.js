function run() {
    LaunchBar.hide();
    var binary = Action.path + '/Contents/Resources/join-next-meeting';
    LaunchBar.execute('/bin/sh', '-c', binary + ' 2>/dev/null &');
}
