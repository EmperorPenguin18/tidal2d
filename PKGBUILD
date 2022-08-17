# Maintainer: Sebastien MacDougall-Landry

pkgname=tidalpp
pkgver=0.1
pkgrel=1
pkgdesc='Simple game engine'
url='https://github.com/EmperorPenguin18/tidalpp/'
source=("https://github.com/EmperorPenguin18/$pkgname/archive/v$pkgver.tar.gz")
arch=('x86_64')
license=('LGPL3')
depends=('sdl2' 'physfs' 'cjson')
sha256sums=('')

build () {
  cd "$srcdir/$pkgname-$pkgver"
  make release
}

package () {
  cd "$srcdir/$pkgname-$pkgver"
  make install
}
