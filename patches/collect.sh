#This basically packages up all your FFmpeg static/shared builds into .7z files

cd sandbox/win32/ffmpeg_git
git_version=`git rev-parse --short HEAD`
cd ../../..
cd sandbox/win32/ffmpeg_git
git_64_version=`git rev-parse --short HEAD`
cd ../../..
if [[ $git_version != $git_64_version ]]; then
  echo "64 and 32 bit versions don't match, hesitating to use this script..."
  return -1
fi
mkdir -p distros # -p so it doesn't warn
date=`date +%Y-%m-%d`
date="$date-g$git_version"
echo "creating distro for $date ffmpeg $git_version"

file="distro-$date"
root="distros/$file"
rm -rf $root
mkdir -p "$root/32-bit"
mkdir -p "$root/64-bit"

dir="$root/32-bit/ffmpeg-static"
if [ -f ./sandbox/win32/ffmpeg_git/ffmpeg.exe ]; then
  mkdir $dir
fi

cp ./sandbox/win32/ffmpeg_git/ffmpeg.exe "$dir"
cp ./sandbox/win32/ffmpeg_git/ffplay.exe "$dir"
cp ./sandbox/win32/ffmpeg_git/ffmpeg_g.exe "$dir"

dir="$root/64-bit/ffmpeg-static"
if [ -f ./sandbox/x86_64/ffmpeg_git/ffmpeg.exe ]; then
  mkdir $dir
  cp ./sandbox/x86_64/ffmpeg_git/ffmpeg.exe "$dir"
  cp ./sandbox/x86_64/ffmpeg_git/ffplay.exe "$dir"
  cp ./sandbox/x86_64/ffmpeg_git/ffmpeg_g.exe "$dir"
fi

do_shareds() {
  dir="$root/32-bit/ffmpeg-shared"
  mkdir $dir

  cp ./sandbox/win32/ffmpeg_git_shared/ffmpeg.exe "$dir"
  cp ./sandbox/win32/ffmpeg_git_shared/ffplay.exe "$dir"
  cp ./sandbox/win32/ffmpeg_git_shared/ffmpeg_g.exe "$dir"

  cp ./sandbox/win32/ffmpeg_git_shared/*/*-*.dll     "$dir"  # have to flatten it
  ./sandbox/mingw-w64-i686/bin/i686-w64-mingw32-strip $dir/*.dll # XXX why?

  dir="$root/64-bit/ffmpeg-shared"
  mkdir $dir

  cp ./sandbox/x86_64/ffmpeg_git_shared/ffmpeg.exe "$dir"
  cp ./sandbox/x86_64/ffmpeg_git_shared/ffplay.exe "$dir"
  cp ./sandbox/x86_64/ffmpeg_git_shared/ffmpeg_g.exe "$dir"

  cp ./sandbox/x86_64/ffmpeg_git_shared/*/*-*.dll "$dir"
  ./sandbox/mingw-w64-x86_64/bin/x86_64-w64-mingw32-strip $dir/*.dll
}

#do_shareds


copy_from() {
 # if you want other exe's like x264.exe ...
 from_dir=$1 # like win32
 to_dir=$2 # like 32-bit

  cd sandbox/$from_dir
  for file2 in `find . -name MP4Box.exe` `find . -name mplayer.exe` `find . -name mencoder.exe` `find . -name avconv.exe` `find . -name avprobe.exe` `find . -name x264.exe`; do
    cp $file2 "../../$root/$to_dir"
  done
  cd ../..
  if [[ -f ./sandbox/$from_dir/vlc_rdp/vlc-2.2.0-git/vlc.exe ]]; then
    cp -r ./sandbox/$from_dir/vlc_rdp/vlc-2.2.0-git $root/$to_dir/vlc
  fi
}

# copy_from win32 32-bit
# copy_from x86_64 64-bit

create_zips() {
  cd distros
  # os x: brew install p7zip
  # -mx=1 for fastest compression speed [but biggest file ...]
  # 7zr -mx=1 a "$file.7z" "$file/*" || 7za a "$file.7z" "$file/*"  # some have a package with only 7za, see https://github.com/rdp/ffmpeg-windows-build-helpers/issues/16
  zip -r $file.zip $file/*
  cd ..
  echo "created distros/$file.zip"
}

create_zips

