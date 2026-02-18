install: install-binary install-action

install-binary:
    swift build -c release
    echo "Built .build/release/join-next-meeting"
    cp .build/release/join-next-meeting ~/.local/bin/join-next-meeting
    echo "Copied to ~/.local/bin/join-next-meeting"

install-action:
    cp -r "LaunchBar Action/Join Next Meeting.lbaction" ~/Library/Application\ Support/LaunchBar/Actions/
    echo "Installed Join Next Meeting.lbaction to LaunchBar"
