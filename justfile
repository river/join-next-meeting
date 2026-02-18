install:
    swift build -c release
    echo "Built join-next-meeting"
    cp .build/release/join-next-meeting "LaunchBar Action/Join Next Meeting.lbaction/Contents/Resources/join-next-meeting"
    echo "Bundled binary into lbaction"

    zip -r "Join Next Meeting.lbaction.zip" "LaunchBar Action/Join Next Meeting.lbaction"
    echo "Created zip of lbaction binary"

    rm -rf ~/Library/Application\ Support/LaunchBar/Actions/Join\ Next\ Meeting.lbaction
    cp -r "LaunchBar Action/Join Next Meeting.lbaction" ~/Library/Application\ Support/LaunchBar/Actions/
    echo "Installed Join Next Meeting.lbaction to LaunchBar"
