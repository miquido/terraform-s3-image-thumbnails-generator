# Library Versions
WEBP_VERSION=1.2.4
X265_VERSION=3.5
LIBDE265_VERSION=1.0.9
LIBHEIF_VERSION=1.13.0
VIPS_VERSION=8.13.3
SHARP_VERSION=0.31.2

PREFIX_PATH=/opt

export PKG_CONFIG_PATH=$(PREFIX_PATH)/lib/pkgconfig

build-SharpHEICLayer: libvips
	mkdir -p "nodejs"
	mkdir -p "lib"

	# sharp uses several of the libs we installed or compiled. extract the full list and copy all of those into /opt/lib
	# extract list with ldd from sharp.node, manipulate a bit with sed to only get the absolute paths, then copy
	LD_LIBRARY_PATH=$(PREFIX_PATH)/lib npm --prefix "nodejs/" --production install sharp@$(SHARP_VERSION)
	LD_LIBRARY_PATH=$(PREFIX_PATH)/lib ldd nodejs/node_modules/sharp/build/Release/sharp-linux-x64.node | sed -nE "s/^[^\/\n]*(\/[^ ]+)(.*)/\1/p" | xargs cp -t lib/

libwebp:
	# libwebp
	curl -L https://github.com/webmproject/libwebp/archive/v$(WEBP_VERSION).tar.gz | tar zx
	cd libwebp-$(WEBP_VERSION) && ./autogen.sh && ./configure --enable-libwebpmux --prefix=$(PREFIX_PATH) && make V=0 && make install
	rm -rf libwebp-$(WEBP_VERSION)

x265:
	# x265
	git clone --branch $(X265_VERSION) --depth 1 https://bitbucket.org/multicoreware/x265_git.git
	cd ./x265_git/build/linux && \
		cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=$(PREFIX_PATH) ../../source && \
		make && \
		make install
	rm -rf x265_git

libde265: x265
	# libde265
	curl -L https://github.com/strukturag/libde265/releases/download/v$(LIBDE265_VERSION)/libde265-$(LIBDE265_VERSION).tar.gz | tar zx
	cd libde265-$(LIBDE265_VERSION) && ./autogen.sh && ./configure --disable-dec265 --disable-sherlock265 --prefix=$(PREFIX_PATH) && make V=0 && make install
	rm -rf libde265-$(LIBDE265_VERSION)

libheif: libde265 x265
	# libheif
	curl -L https://github.com/strukturag/libheif/releases/download/v$(LIBHEIF_VERSION)/libheif-$(LIBHEIF_VERSION).tar.gz | tar zx
	cd libheif-$(LIBHEIF_VERSION) && ./autogen.sh && ./configure --prefix=$(PREFIX_PATH) && make V=0 && make install
	rm -rf libheif-$(LIBHEIF_VERSION)

libvips: installLib libheif libwebp
	# libvips
	curl -L https://github.com/libvips/libvips/releases/download/v$(VIPS_VERSION)/vips-$(VIPS_VERSION).tar.gz | tar zx
	cd vips-$(VIPS_VERSION) && ./configure --prefix=$(PREFIX_PATH) && make V=0 && make install
	rm -rf vips-$(VIPS_VERSION)

installLib:
	yum install -y yum-plugin-ovl \
		glib2-devel \
		expat-devel \
		libjpeg-devel \
		libjpeg-turbo-devel \
		libpng-devel \
		giflib-devel \
		libexif-devel \
		librsvg2-devel \
		libtiff-devel \
		ImageMagick-devel \
		lcms2-devel \
		cmake
