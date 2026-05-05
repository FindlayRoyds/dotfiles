# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Open fish shell when running interactively
if [ -x /usr/bin/fish ] && [ -z "$FISH_VERSION" ]; then
    exec /usr/bin/fish
fi
