install:
    swift build -c release
    echo "Built .build/release/join-next-meeting"
    cp .build/release/join-next-meeting ~/.local/bin/join-next-meeting
    echo "Copied to ~/.local/bin/join-next-meeting"
