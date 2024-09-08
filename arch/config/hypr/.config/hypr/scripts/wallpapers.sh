wallpaper_directory="$HOME/Pictures/Wallpapers/"

mkdir -p "$HOME/.cache/wallpapers/"

# Todo: Add a routine to pick a random wallpaper from the directory
file=$(find "$wallpaper_directory" -type f -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" | shuf -n 1)
echo "$file"

cp "$file" "$HOME/.cache/wallpapers/wallpaper.jpg"
