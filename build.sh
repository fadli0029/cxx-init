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
  echo "  -h, --help       Show this help message"
  exit 0
fi

run_tidy=false
build_type="Release"
compiler="clang++"
strict_warnings=false
sanitize=false

for arg in "$@"; do
  case "$arg" in
    --clean) rm -rf build ;;
    --tidy) run_tidy=true ;;
    --debug) build_type="Debug" ;;
    --compiler=*) compiler="${arg#*=}" ;;
    --strict) strict_warnings=true ;;
    --sanitize) sanitize=true ;;
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

cmake $cmake_args
cmake --build build

if $run_tidy; then
  echo "Running clang-tidy..."
  find src -name '*.cpp' -exec clang-tidy -p build {} +
fi
