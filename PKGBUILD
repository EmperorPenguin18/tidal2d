# Maintainer: Sebastien MacDougall-Landry

pkgname=tidalpp
pkgver=0.1
pkgrel=1
pkgdesc='Simple game engine'
url='https://github.com/EmperorPenguin18/tidalpp/'
source=("https://github.com/EmperorPenguin18/$pkgname/archive/v$pkgver.tar.gz")
arch=('x86_64')
license=('LGPL')
depends=('sdl2' 'physfs')
sha256sums=('5ae8937d6e0510c77455c934a1e9e5e1627eb1036c969ef4f28f97ff213d9590')

build () {
  cd "$srcdir/$pkgname-$pkgver"
  make release
}

package () {
  cd "$srcdir/$pkgname-$pkgver"
  make install
}
