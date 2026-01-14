#!/bin/bash

if [[ "$1" == "--help" || "$1" == "-h" || "$1" == "--h" ]]; then
  echo "Usage: ./build.sh [options]"
  echo ""
  echo "Options:"
  echo "  --clean          Remove build directory before building"
  echo "  --debug          Build with debug symbols and assertions"
  echo "  --strict         Treat warnings as errors (-Werror)"
  echo "  --sanitize       Enable ASAN and UBSAN"
  echo "  --tidy           Run clang-tidy after build"
  echo "  --compiler=NAME  Use specified compiler (default: clang++)"
  echo "  --verbose        Show actual compiler commands"
  echo "  -h, --help       Show this help message"
  echo ""
  echo "Defaults:"
  echo "  Build type: Release"
  echo "  Compiler:   clang++"
  echo "  Warnings:   See CMakeLists.txt (cpp-best-practices + OpenSSF hardening)"
  exit 0
fi

run_tidy=false
build_type="Release"
compiler="clang++"
strict_warnings=false
sanitize=false
verbose=false

for arg in "$@"; do
  case "$arg" in
    --clean) rm -rf build ;;
    --tidy) run_tidy=true ;;
    --debug) build_type="Debug" ;;
    --compiler=*) compiler="${arg#*=}" ;;
    --strict) strict_warnings=true ;;
    --sanitize) sanitize=true ;;
    --verbose) verbose=true ;;
    *)
      echo "Error: unknown option '$arg'"
      echo "Run './build.sh --help' for usage"
      exit 1
      ;;
  esac
done

if ! command -v "$compiler" &> /dev/null; then
  echo "Error: compiler '$compiler' not found"
  exit 1
fi

cmake_args="-B build -G Ninja -DCMAKE_CXX_COMPILER=$compiler -DCMAKE_BUILD_TYPE=$build_type"
if $strict_warnings; then
  cmake_args="$cmake_args -DSTRICT_WARNINGS=ON"
fi
if $sanitize; then
  cmake_args="$cmake_args -DENABLE_SANITIZERS=ON"
fi

echo ""
echo "Build:    $build_type"
echo "Compiler: $compiler"
echo "Strict:   $strict_warnings"
echo "Sanitize: $sanitize"
echo ""
echo ">> cmake $cmake_args"
cmake $cmake_args

if $verbose; then
  cmake --build build -- -v
else
  cmake --build build
fi

if $run_tidy; then
  echo "Running clang-tidy..."
  find src -name '*.cpp' -exec clang-tidy -p build {} +
fi
