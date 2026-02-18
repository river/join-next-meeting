function run() {
    LaunchBar.hide();
    LaunchBar.execute('/bin/sh', '-c', 'exec ~/.local/bin/join-next-meeting 2>/dev/null &');
}
