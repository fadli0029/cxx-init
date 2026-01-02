# cxx-init

I've been wanting to do this since this is such a mundane/repititive task, so here it is. You may not need it depending on the editor/ide you use, I use nvim (jdhao's nvim config but modified), often I need the config files you see here.

This is a very minimal and opinionated C++23 project scaffolding with CMake, clang-format, and clang-tidy configs.

## What's Included

- `cxx-init`: creates a new C++ project with CMake, C++23 modules (`import std;`), and tooling configs
- `cxx-fix`: runs `clang-tidy --fix` on source files
- `.clang-format`: formatting config (Google-based, includes both C++ and C sections)
- `.clang-tidy`: linting config with C++ Core Guidelines, modernize, bugprone, and performance checks

## Installation

Clone the repo and symlink the scripts to a directory in your `$PATH`:

```bash
git clone https://github.com/fadli0029/cxx-init.git ~/path/to/cxx-init

ln -s ~/path/to/cxx-init/cxx-init ~/.local/bin/
ln -s ~/path/to/cxx-init/cxx-fix ~/.local/bin/
```

where `~/path/to/` is wherever the path you want to put `cxx-init in.`

The scripts resolve symlinks to find config files in the repo directory.

## Usage

Create a new project:

```bash
cxx-init myproject
cd myproject
./build.sh
```

__Note:__ Run `./build.sh` at least once before opening in your editor. This generates `compile_commands.json` which clangd needs for intellisense.

Build with clang-tidy:

```bash
./build.sh --tidy
```

Auto-fix clang-tidy warnings:

```bash
cxx-fix              # fix all files in src/
cxx-fix src/main.cpp # fix specific file
```

## Project Structure

Generated projects have this layout:

```
myproject/
├── src/
│   └── main.cpp
├── include/
├── build.sh
├── CMakeLists.txt
├── .clangd
├── .clangd-modules
├── .clang-tidy
└── .clang-format
```

## Naming Conventions

The `.clang-tidy` config enforces:

| Category | Style |
|----------|-------|
| Types | `CamelCase` |
| Functions/methods | `lower_case` |
| Variables | `lower_case` |
| Member variables | `lower_case_`  |
| Constants | `kCamelCase` |
| Macros | `UPPER_CASE` |

For std-lib style naming (all `lower_case`), uncomment the overrides at the bottom of `.clang-tidy` and comment out the corresponding defaults above.

## C++23 Modules with CMake

The generated `CMakeLists.txt` enables `import std;` through these settings:

```cmake
cmake_minimum_required(VERSION 4.0)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD "d0edc3af-4c50-42ea-a356-e2862fe7a444")

set(CMAKE_CXX_SCAN_FOR_MODULES ON)

add_executable(myproject src/main.cpp)
set_target_properties(myproject PROPERTIES CXX_MODULE_STD 1)
```

Key parts:

- `CMAKE_EXPERIMENTAL_CXX_IMPORT_STD`: experimental UUID that enables `import std;`. This UUID changes between CMake versions. Check [CMake experimental.rst](https://github.com/Kitware/CMake/blob/master/Help/dev/experimental.rst) for the current value.
- `CMAKE_CXX_SCAN_FOR_MODULES`: tells CMake to scan sources for module dependencies
- `CXX_MODULE_STD 1`: target property that provides the standard library module

If builds fail after a CMake update, the UUID likely changed. Update it from the link above.

## Requirements

- CMake 4.0+
- Clang/Clang++ with C++23 modules support
- Ninja
- clang-format
- clang-tidy
