// Standard extendr entrypoint: the Rust staticlib exports
// R_init_dwg2geo_extendr; this shim forwards R's init call to it.
#include <R.h>
#include <Rinternals.h>

void R_init_dwg2geo_extendr(void *dll);

void R_init_dwg2geo(void *dll) {
    R_init_dwg2geo_extendr(dll);
}
