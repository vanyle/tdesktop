call "D:\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars32.bat"

SET PATH=%cd%\ThirdParty\Strawberry\perl\bin;%cd%\ThirdParty\Python27;%cd%\ThirdParty\NASM;%cd%\ThirdParty\jom;%cd%\ThirdParty\cmake\bin;%cd%\ThirdParty\yasm;%PATH%

mkdir Libraries
cd Libraries

cd ..
git clone --recursive https://github.com/telegramdesktop/tdesktop.git

cd Libraries

git clone https://github.com/desktop-app/patches.git
cd patches
git checkout 41ead72
cd ..

git clone https://github.com/desktop-app/lzma.git
cd lzma\C\Util\LzmaLib
msbuild LzmaLib.sln /property:Configuration=Debug /property:Platform="x86"
msbuild LzmaLib.sln /property:Configuration=Release /property:Platform="x86"
cd ..\..\..\..

git clone https://github.com/openssl/openssl.git openssl_1_1_1
cd openssl_1_1_1
git checkout OpenSSL_1_1_1-stable
perl Configure no-shared no-tests debug-VC-WIN32
nmake
mkdir out32.dbg
move libcrypto.lib out32.dbg
move libssl.lib out32.dbg
move ossl_static.pdb out32.dbg\ossl_static
nmake clean
move out32.dbg\ossl_static out32.dbg\ossl_static.pdb
perl Configure no-shared no-tests VC-WIN32
nmake
mkdir out32
move libcrypto.lib out32
move libssl.lib out32
move ossl_static.pdb out32
cd ..

git clone https://github.com/desktop-app/zlib.git
cd zlib\contrib\vstudio\vc14
msbuild zlibstat.vcxproj /property:Configuration=Debug /property:Platform="x86"
msbuild zlibstat.vcxproj /property:Configuration=ReleaseWithoutAsm /property:Platform="x86"
cd ..\..\..\..

git clone -b v4.0.1-rc2 https://github.com/mozilla/mozjpeg.git
cd mozjpeg
cmake . ^
    -G "Visual Studio 16 2019" ^
    -A Win32 ^
    -DWITH_JPEG8=ON ^
    -DPNG_SUPPORTED=OFF
cmake --build . --config Debug
cmake --build . --config Release
cd ..


git clone https://github.com/kcat/openal-soft.git
cd openal-soft
git checkout openal-soft-1.21.0
cd build
cmake .. ^
    -G "Visual Studio 16 2019" ^
    -A Win32 ^
    -D LIBTYPE:STRING=STATIC ^
    -D FORCE_STATIC_VCRT=ON
msbuild OpenAL.vcxproj /property:Configuration=Debug
msbuild OpenAL.vcxproj /property:Configuration=RelWithDebInfo
cd ..\..


git clone https://github.com/google/breakpad

cd breakpad
git checkout a1dbcdcb43
git apply ../patches/breakpad.diff
cd src
git clone https://github.com/google/googletest testing


cd client\windows
gyp --no-circular-check breakpad_client.gyp --format=ninja
cd ..\..
ninja -C out/Debug common crash_generation_client exception_handler
ninja -C out/Release common crash_generation_client exception_handler
cd tools\windows\dump_syms
gyp dump_syms.gyp
msbuild dump_syms.vcxproj /property:Configuration=Release
cd ..\..\..\..\..


git clone https://github.com/telegramdesktop/opus.git
cd opus
git checkout tdesktop
cd win32\VS2015
msbuild opus.sln /property:Configuration=Debug /property:Platform="Win32"
msbuild opus.sln /property:Configuration=Release /property:Platform="Win32"

cd ..\..\..\..

SET PATH_BACKUP_=%PATH%
SET PATH=D:\msys64\usr\bin;%PATH%
cd Libraries

git clone https://github.com/FFmpeg/FFmpeg.git ffmpeg
cd ffmpeg
git checkout release/4.2

set CHERE_INVOKING=enabled_from_arguments
set MSYS2_PATH_TYPE=inherit
D:\msys64\usr\bin\bash.exe --login ../patches/build_ffmpeg_win.sh

SET PATH=%PATH_BACKUP_%
cd ..

SET LibrariesPath=%cd%
git clone git://code.qt.io/qt/qt5.git qt_5_15_2
cd qt_5_15_2
perl init-repository --module-subset=qtbase,qtimageformats
git checkout v5.15.2
git submodule update qtbase qtimageformats
cd qtbase
for /r %i in (..\..\patches\qtbase_5_15_2\*) do git apply %i
cd ..

configure ^
    -prefix "%LibrariesPath%\Qt-5.15.2" ^
    -debug-and-release ^
    -force-debug-info ^
    -opensource ^
    -confirm-license ^
    -static ^
    -static-runtime ^
    -no-opengl ^
    -openssl-linked ^
    -I "%LibrariesPath%\openssl_1_1_1\include" ^
    OPENSSL_LIBS_DEBUG="%LibrariesPath%\openssl_1_1_1\out32.dbg\libssl.lib %LibrariesPath%\openssl_1_1_1\out32.dbg\libcrypto.lib Ws2_32.lib Gdi32.lib Advapi32.lib Crypt32.lib User32.lib" ^
    OPENSSL_LIBS_RELEASE="%LibrariesPath%\openssl_1_1_1\out32\libssl.lib %LibrariesPath%\openssl_1_1_1\out32\libcrypto.lib Ws2_32.lib Gdi32.lib Advapi32.lib Crypt32.lib User32.lib" ^
    -I "%LibrariesPath%\mozjpeg" ^
    LIBJPEG_LIBS_DEBUG="%LibrariesPath%\mozjpeg\Debug\jpeg-static.lib" ^
    LIBJPEG_LIBS_RELEASE="%LibrariesPath%\mozjpeg\Release\jpeg-static.lib" ^
    -mp ^
    -nomake examples ^
    -nomake tests ^
    -platform win32-msvc


jom -j8
jom -j8 install
cd ..


git clone --recursive https://github.com/desktop-app/tg_owt.git

cd tg_owt
mkdir out
cd out
mkdir Debug
cd Debug
cmake -G Ninja ^
    -DCMAKE_BUILD_TYPE=Debug ^
    -DTG_OWT_SPECIAL_TARGET=win ^
    -DTG_OWT_LIBJPEG_INCLUDE_PATH=%cd%/../../../mozjpeg ^
    -DTG_OWT_OPENSSL_INCLUDE_PATH=%cd%/../../../openssl_1_1_1/include ^
    -DTG_OWT_OPUS_INCLUDE_PATH=%cd%/../../../opus/include ^
    -DTG_OWT_FFMPEG_INCLUDE_PATH=%cd%/../../../ffmpeg ../..
ninja
cd ..
mkdir Release
cd Release
cmake -G Ninja ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DTG_OWT_SPECIAL_TARGET=win ^
    -DTG_OWT_LIBJPEG_INCLUDE_PATH=%cd%/../../../mozjpeg ^
    -DTG_OWT_OPENSSL_INCLUDE_PATH=%cd%/../../../openssl_1_1_1/include ^
    -DTG_OWT_OPUS_INCLUDE_PATH=%cd%/../../../opus/include ^
    -DTG_OWT_FFMPEG_INCLUDE_PATH=%cd%/../../../ffmpeg ../..
ninja
cd ..\..\..

echo Done!
pause