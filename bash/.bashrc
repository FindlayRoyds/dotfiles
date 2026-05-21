# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Open fish shell when running interactively
if [ -z "$FISH_VERSION" ]; then
    for _fish in /opt/homebrew/bin/fish /usr/local/bin/fish /home/linuxbrew/.linuxbrew/bin/fish; do
        if [ -x "$_fish" ]; then
            exec "$_fish"
        fi
    done
fi
