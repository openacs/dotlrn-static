ad_library {

        Automated tests for the dotlrn-static package.

        @author Héctor Romojaro <hector.romojaro@gmail.com>
        @creation-date 2019-09-10

}

aa_register_case \
    -cats {api smoke production_safe} \
    -procs {
        dotlrn_static::package_key
        dotlrn_static::my_package_key
        dotlrn_static::applet_key
    } \
    dotlrn_static__keys {

        Simple test for the various dotlrn_static::..._key procs.

        @author Héctor Romojaro <hector.romojaro@gmail.com>
        @creation-date 2019-09-10
} {
    aa_equals "Package key" "[dotlrn_static::package_key]" "static-portlet"
    aa_equals "Applet key" "[dotlrn_static::applet_key]" "dotlrn_static"
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
