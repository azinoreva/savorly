# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION 3.5)

file(MAKE_DIRECTORY
  "C:/Users/azino/Desktop/savorly/savorly/build/windows/x64/_deps/objectbox-download-src"
  "C:/Users/azino/Desktop/savorly/savorly/build/windows/x64/_deps/objectbox-download-build"
  "C:/Users/azino/Desktop/savorly/savorly/build/windows/x64/_deps/objectbox-download-subbuild/objectbox-download-populate-prefix"
  "C:/Users/azino/Desktop/savorly/savorly/build/windows/x64/_deps/objectbox-download-subbuild/objectbox-download-populate-prefix/tmp"
  "C:/Users/azino/Desktop/savorly/savorly/build/windows/x64/_deps/objectbox-download-subbuild/objectbox-download-populate-prefix/src/objectbox-download-populate-stamp"
  "C:/Users/azino/Desktop/savorly/savorly/build/windows/x64/_deps/objectbox-download-subbuild/objectbox-download-populate-prefix/src"
  "C:/Users/azino/Desktop/savorly/savorly/build/windows/x64/_deps/objectbox-download-subbuild/objectbox-download-populate-prefix/src/objectbox-download-populate-stamp"
)

set(configSubDirs Debug)
foreach(subDir IN LISTS configSubDirs)
    file(MAKE_DIRECTORY "C:/Users/azino/Desktop/savorly/savorly/build/windows/x64/_deps/objectbox-download-subbuild/objectbox-download-populate-prefix/src/objectbox-download-populate-stamp/${subDir}")
endforeach()
if(cfgdir)
  file(MAKE_DIRECTORY "C:/Users/azino/Desktop/savorly/savorly/build/windows/x64/_deps/objectbox-download-subbuild/objectbox-download-populate-prefix/src/objectbox-download-populate-stamp${cfgdir}") # cfgdir has leading slash
endif()
