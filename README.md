# Telegram Desktop – Fork

This is a fork of the Telegram Desktop that you can find here: https://github.com/telegramdesktop/tdesktop

## Polling changes

The polling defaults are changed to be nicer. (Edit made in `create_poll_box.cpp`)
Now, by default:

- Anonymous answers is unchecked
- Multiple votes is checked

Those defaults are nicer when doing polls with friends :)

## Building

To make building easier, 2 scripts are provided. You'll still need to install all the required program but the compilation of the libraries will be easier.

Structure of the folders when building:
- `TBuild/tdesktop/ <this git repo> `
- `TBuild/build.bat`
- `TBuild/build2.bat`
- `TBuild/Libraries/ <empty>`
- `TBuild/ThirdParty/ <The third party programs that are needed>`

You'll need to move the `bat` files one folder up for them to work.
Run `build.bat` then `build2.bat`

The detailed instructions are found here: [docs/building-msvc](docs/building-msvc)