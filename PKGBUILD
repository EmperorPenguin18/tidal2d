# Maintainer: Sebastien MacDougall-Landry

pkgname=tidalpp
pkgver=0.2
pkgrel=1
pkgdesc='Simple game engine'
url='https://github.com/EmperorPenguin18/tidalpp/'
source=("https://github.com/EmperorPenguin18/$pkgname/archive/$pkgver.tar.gz")
arch=('x86_64')
license=('LGPL3')
depends=('sdl2' 'chipmunk' 'stb' 'nanosvg' 'lua')
optdepends=('openssl' 'emscripten')
makedepends=('cmake')
sha256sums=('14d92bb09c04c0bef9e9028244e70272e6d39cba764402b4e5981d83c5898f87')

build () {
  cd "$srcdir/$pkgname-$pkgver"
  mkdir build
  cd build
  cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release
  cmake --build .
}

package () {
  cd "$srcdir/$pkgname-$pkgver"
  cmake --build . --target install
}
