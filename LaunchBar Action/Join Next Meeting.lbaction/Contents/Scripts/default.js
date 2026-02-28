function run() {
    LaunchBar.hide();
    var binary = Action.path + '/Contents/Resources/join-next-meeting';
    LaunchBar.execute('/bin/sh', '-c', 'exec "$0" &', binary);
}
