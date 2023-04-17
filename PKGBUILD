# Maintainer: Sebastien MacDougall-Landry

pkgname=tidalpp
pkgver=0.1
pkgrel=1
pkgdesc='Simple game engine'
url='https://github.com/EmperorPenguin18/tidalpp/'
source=("https://github.com/EmperorPenguin18/$pkgname/archive/$pkgver.tar.gz")
arch=('x86_64')
license=('LGPL3')
depends=('sdl2' 'physfs' 'cjson' 'chipmunk' 'sdl2_image' 'soloud' 'sdl2_fontcache' 'openssl')
sha256sums=('14d92bb09c04c0bef9e9028244e70272e6d39cba764402b4e5981d83c5898f87')

build () {
  cd "$srcdir/$pkgname-$pkgver"
  make release
}

package () {
  cd "$srcdir/$pkgname-$pkgver"
  install -Dm755 tidalpp -t "$pkgdir/usr/bin"
}
