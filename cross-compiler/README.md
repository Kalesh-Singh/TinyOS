# Building a Cross Compiler for our OS #

*NOTE: The target machine we are using is a 32-bit intel processor (i386-elf), but the target can be updated to create a cross
compiler for other target machines as needed*

## Preparing for the Build ##

We need the following dependencies inorder to build GCC:
+ A Unix like environment
+ gcc
+ g++
+ make
+ bison
+ flex
+ libgmp3-dev
+ libmpc-dev
+ libmprf-dev
+ texinfo

These can all be installed on Debian distributions using 
`sudo apt install [dependecy name]`.

We need to build `binutils` and a `cross-compiled gcc`, which we will put into `/usr/local/i386elf-cc`, so let's export
some paths:

```bash
export PREFIX="/usr/local/i386elf-cc"
export TARGET=i386-elf
export PATH="$PREFIX/bin:$PATH"
```

## binutils ##

Downloading the source and building binutils:

```bash
mkdir /tmp/src
cd /tmp/src
curl -O https://ftp.gnu.org/gnu/binutils/binutils-2.32.tar.gz # If the link 404's, look for a more recent version
tar xf binutils-2.32.tar.gz
mkdir binutils-build
cd binutils-build
../binutils-2.32/configure --target=$TARGET --enable-interwork --enable-multilib --disable-nls --disable-werror --prefix=$PREFIX 2>&1 | tee configure.log
make all install 2>&1 | tee make.log
```

## gcc ##

Downloading the source and building the cross complied gcc:

```bash
cd /tmp/src
curl -O https://ftp.gnu.org/gnu/gcc/gcc-8.3.0/gcc-8.3.0.tar.gz 
tar xf gcc-8.3.0.tar.gz
mkdir gcc-build
cd gcc-build
../gcc-8.3.0/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --disable-libssp --enable-languages=c --without-headers
make all-gcc
make all-target-libgcc
make install-gcc
make install-target-libgcc
```
