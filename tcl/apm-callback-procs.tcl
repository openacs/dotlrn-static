ad_library {
}

namespace eval dotlrn_static::apm {}

ad_proc -private dotlrn_static::apm::upgrade {
    -from_version_name
    -to_version_name
} {
    Upgrade logics for dotlrn_static
} {
    apm_upgrade_logic \
	-from_version_name $from_version_name \
	-to_version_name $to_version_name \
	-spec {
	    2.10.0 2.10.1 {
                #
                # We expect static-portlet to be mounted underneath
                # the /dotlrn/applets site-node, but over time this
                # got broken and some may have it installed underneath
                # /dotlrn instead. We rectify the situation.
                #

                set applets_node [site_node::get -url [dotlrn_applet::get_url]/]
                set applets_node_id [dict get $applets_node node_id]

                set package_key [dotlrn_static::package_key]

                #
                # Check if the current mountpoint is fine.
                #
                if {![db_0or1row is_mountpoint_ok {
                    select object_id as static_portlet_package_id
                    from site_nodes n, apm_packages p
                    where n.parent_id = :applets_node_id
                      and p.package_id = n.object_id
                      and p.package_key = :package_key
                }]} {
                    #
                    # When it is not, make sure an instance exists
                    # underneath dotlrn.
                    #
                    set dotlrn_node [site_node::get -url [dotlrn::get_url]]
                    set dotlrn_node_id [dict get $dotlrn_node node_id]

                    if {![db_0or1row is_applet_under_dotlrn {
                        select node_id as static_portlet_node_id,
                               object_id as static_portlet_package_id
                        from site_nodes n, apm_packages p
                        where n.parent_id = :dotlrn_node_id
                        and p.package_id = n.object_id
                        and p.package_key = :package_key
                    }]} {
                        #
                        # We did not found static-portlet in any of
                        # the places where it was expected. We give up
                        # and notify the situation.
                        #
                        set msg "WARNING!! Could not locate '$package_key' mountpoint!"
                        apm_ns_write_callback $msg
                        ns_log warning $msg
                        return
                    }

                    #
                    # Here we have static portlet mounted wrongly
                    # underneath /dotlrn. We unmout it and remount it
                    # underneath /dotlrn/applets.
                    #

                    apm_ns_write_callback "Remounting '$package_key' instance '$static_portlet_package_id' from node '/dotlrn' to node '/dotlrn/applets'"

                    db_transaction {
                        site_node::unmount \
                            -node_id $static_portlet_node_id

                        set new_node_id [site_node::new \
                                             -name $package_key \
                                             -parent_id $applets_node_id]

                        site_node::mount \
                            -node_id $new_node_id \
                            -object_id $static_portlet_package_id

                        site_node::delete \
                            -node_id $static_portlet_node_id
                    }
                } else {
                    apm_ns_write_callback "'$static_portlet_package_id' is already mounted underneath '/dotlrn/applets', nothing to do."
                }
	    }
	}
}
