app_name=xharvest
app_dir=$(shell pwd)/src
dist_dir=dist
build_dir=build
python_ver=3.7.7
python_cachedir=$(app_dir)/cache/appimage
gtk_ver_major_minor=3.24
gtk_ver_patch=13
gtk_ver=$(gtk_ver_major_minor).$(gtk_ver_patch)
glib_ver_major_minor=2.30
glib_ver_patch=3
glib_ver=$(glib_ver_major_minor).$(glib_ver_patch)
pango_ver_major_minor=1.44
pango_ver_patch=7
pango_ver=$(pango_ver_major_minor).$(pango_ver_patch)
atk_ver_major_minor=2.34
atk_ver_patch=1
atk_ver=$(atk_ver_major_minor).$(atk_ver_patch)
gobject_introspection_ver_major_minor=1.62
gobject_introspection_ver_patch=0
gobject_introspection_ver=$(gobject_introspection_ver_major_minor).$(gobject_introspection_ver_patch)

export ARCH=x86_64

# ----------------------------------------------------[Downloading Dependencies]

download_python:
ifeq (,$(wildcard $(build_dir)/Python-$(python_ver).tar.xz))
	curl -O \
		https://www.python.org/ftp/python/$(python_ver)/Python-$(python_ver).tar.xz
	mv Python-$(python_ver).tar.xz $(build_dir)/.
endif

download_gtk:
ifeq (,$(wildcard $(build_dir)/gtk+-$(gtk_ver).tar.xz))
	curl -O \
		https://download.gnome.org/sources/gtk+/$(gtk_ver_major_minor)/gtk+-$(gtk_ver).tar.xz
	mv gtk+-$(gtk_ver).tar.xz $(build_dir)/.
endif

download_glib:
ifeq (,$(wildcard $(build_dir)/glib-$(glib_ver).tar.xz))
	curl -O \
		https://download.gnome.org/sources/glib/$(glib_ver_major_minor)/glib-$(glib_ver).tar.xz
	mv glib-$(glib_ver).tar.xz $(build_dir)/.
endif

download_pango:
ifeq (,$(wildcard $(build_dir)/pango-$(pango_ver).tar.xz))
	curl -O \
		https://download.gnome.org/sources/pango/$(pango_ver_major_minor)/pango-$(pango_ver).tar.xz
	mv pango-$(pango_ver).tar.xz $(build_dir)/.
endif

download_atk:
ifeq (,$(wildcard $(build_dir)/atk-$(atk_ver).tar.xz))
	curl -O \
		https://download.gnome.org/sources/atk/$(atk_ver_major_minor)/atk-$(atk_ver).tar.xz
	mv atk-$(atk_ver).tar.xz $(build_dir)/.
endif

download_gobject_introspection:
ifeq (,$(wildcard $(build_dir)/gobject-introspection-$(gobject_introspection_ver).tar.xz))
	curl -O \
		https://download.gnome.org/sources/gobject-introspection/$(gobject_introspection_ver_major_minor)/gobject-introspection-$(gobject_introspection_ver).tar.xz
	mv gobject-introspection-$(gobject_introspection_ver).tar.xz $(build_dir)/.
endif	

# ----------------------------------------------------------[Build Dependencies]

build_python: download_python
ifeq (,$(wildcard $(build_dir)/Python-$(python_ver)))
	cd $(build_dir)/ && \
		tar xf Python-$(python_ver).tar.xz
endif
	mkdir -p $(python_cachedir)
	cd $(build_dir)/Python-$(python_ver) && \
		./configure \
			--cache-file="$(python_cachedir)/python.config.cache" \
			--prefix="$(app_dir)/usr" \
			--enable-ipv6 \
			--enable-loadable-sqlite-extensions \
			--enable-shared \
			--with-threads \
			--enable-optimizations \
			--without-ensurepip
	cd $(build_dir)/Python-$(python_ver) && \
		make install

build_gtk:
ifeq (,$(wildcard $(build_dir)/gtk+-$(gtk_ver)))
	cd $(build_dir)/ && \
		tar xf gtk+-$(gtk_ver).tar.xz
endif
	cd $(build_dir)/gtk+-$(gtk_ver) && \
		./configure \
			--prefix="$(app_dir)/usr"
	cd $(build_dir)/gtk+-$(gtk_ver) && \
		make install

pre_build:
	mkdir -p $(build_dir)

build: pre_build build_python

pack:
	mkdir -p $(dist_dir)
	./appimagetool-x86_64.AppImage src/. $(dist_dir)/$(app_name).AppImage

run:
	chmod a+x $(dist_dir)/$(app_name).AppImage
	cd $(dist_dir)/ && \
		./$(app_name).AppImage

