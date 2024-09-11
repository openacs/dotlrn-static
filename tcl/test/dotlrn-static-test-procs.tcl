ad_library {

        Automated tests for the dotlrn-static package.

        @author Héctor Romojaro <hector.romojaro@gmail.com>
        @creation-date 2019-09-10

}

aa_register_case -cats {
    smoke production_safe
} dotlrn_static_mountpoint {
    Make sure the applet is mounted correctly
} {
    set applets_node [site_node::get -url [dotlrn_applet::get_url]/]
    set applets_node_id [dict get $applets_node node_id]

    set package_key [dotlrn_static::package_key]

    aa_true "Applet is mounted under /dotlrn/applets" [db_0or1row is_mounted {
        select 1 from site_nodes n, apm_packages p
        where n.parent_id = :applets_node_id
        and p.package_id = n.object_id
        and p.package_key = :package_key
    }]
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

aa_register_case -procs {
        dotlrn_static::get_pretty_name
    } -cats {
        api
        production_safe
    } dotlrn_static_pretty_name {
        Test get_pretty_name.
} {
    aa_equals "dotlrn-static pretty name" "[dotlrn_static::get_pretty_name]" "[_ [dotlrn_static::pretty_name_key]]"
}

aa_register_case -procs {
        dotlrn_static::add_applet
        dotlrn_static::add_portlet
        dotlrn_static::add_portlet_helper
        dotlrn_static::remove_portlet
        dotlrn_static::remove_applet
        portal::exists_p
    } -cats {
        api
    } dotlrn_static__applet_portlet {
        Test add/remove applet/portlet procs.
} {
    #
    # Helper proc to check portal elements
    #
    proc portal_elements {portal_id} {
        return [db_string elements {
            select count(1)
            from portal_element_map pem,
                 portal_pages pp
           where pp.portal_id = :portal_id
             and pp.page_id = pem.page_id
        }]
    }
    #
    # Start the tests
    #
    aa_run_with_teardown -rollback -test_code {
        #
        # Create test user
        #
        # As this is running in a transaction, it should be cleaned up
        # automatically.
        #
        set portal_user_id [db_nextval acs_object_id_seq]
        set user_info [acs::test::user::create -user_id $portal_user_id]
        #
        # Create portal
        #
        set portal_id [portal::create $portal_user_id]
        set applet_key [dotlrn_static::applet_key]
        if {[portal::exists_p $portal_id]} {
            aa_log "Portal created (portal_id: $portal_id)"
            if {[dotlrn_applet::get_applet_id_from_key -applet_key $applet_key] ne ""} {
                #
                # Remove the applet in advance, if it already exists
                #
                dotlrn_static::remove_applet
                aa_true "Removed existing applet" "[expr {[dotlrn_applet::get_applet_id_from_key -applet_key $applet_key] eq ""}]"
            }
            #
            # Create some content
            #
            set content "Just a test"
            set content_pretty_name "foo"
            set content_format "text/html"
            set content_id [static_portal_content::new \
                                -package_id 0 \
                                -content $content \
                                -pretty_name $content_pretty_name \
                                -format $content_format]
            set args [ns_set create]
            ns_set put $args package_id 0
            ns_set put $args content_id $content_id
            ns_set put $args template_id [portal::get_portal_template_id $portal_id]
            #
            # Add applet
            #
            dotlrn_static::add_applet
            aa_true "Add applet" "[expr {[dotlrn_applet::get_applet_id_from_key -applet_key $applet_key] ne ""}]"
            #
            # Add portlet to portal
            #
            # Set portal type first, as it is checked by 'add_portlet'
            #
            dotlrn::set_type_portal_id -type foo -portal_id $portal_id
            set element_id [dotlrn_static::add_portlet $portal_id]
            aa_equals "Number of portal elements after addition" "[portal_elements $portal_id]" "1"
            #
            # Remove portlet from portal
            #
            dotlrn_static::remove_portlet $portal_id $element_id $args
            aa_equals "Number of portal elements after removal" "[portal_elements $portal_id]" "0"
            #
            # Add portlet to portal using directly the helper
            #
            dotlrn_static::add_portlet_helper $portal_id $args
            aa_equals "Number of portal elements after addition" "[portal_elements $portal_id]" "1"
            #
            # Remove applet
            #
            dotlrn_static::remove_applet
            aa_equals "Remove applet" "[dotlrn_applet::get_applet_id_from_key -applet_key $applet_key]" ""
        } else {
            aa_error "Portal creation failed"
        }
    }
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
