
EAPI=5

PYTHON_COMPAT=( python2_7 )

EGIT_REPO_URI="https://github.com/oldbay/raster_calc.git"
# EGIT_PROJECT="raster_calc-${PV}"
# EGIT_COMMIT=

PYTHON_DEPEND="2"

inherit distutils git-2

DESCRIPTION="Utilites for calculate georaster"
HOMEPAGE=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""

DEPEND="
    dev-python/raster-tools
	dev-python/numpy
	"
RDEPEND="${DEPEND}"

python_install_all() {
        distutils_python_install_all

}
