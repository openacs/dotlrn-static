#
# Procs for DOTLRN static Applet
# Copyright 2001 OpenForce, inc.
# Distributed under the GNU GPL v2
#
# arjun@openforce.net
#
# $Id$

ad_library {
    
    Procs for the dotLRN Static applet
    
    @author arjun@openforce.net
}

namespace eval dotlrn_static {
    
    ad_proc -private my_package_key {
    } {
        return "dotlrn-static"
    }

    ad_proc -public applet_key {} {
	get the applet key
    } {
	return "dotlrn_static"
    }

    ad_proc -public package_key {
    } {
	Get the package_key this applet deals with. 

        This is _unlike_ a package like bboard since there's
        no "static" package but a combined  "static-portlet" 
        package. I named it "static-portlet" instead of 
        "static" since it's tied to (new-portal) so strongly
    } {
	return "static-portlet"
    }

    ad_proc -public get_pretty_name {
    } {
	returns the pretty name
    } {
	return "dotLRN static data"
    }

    ad_proc -public add_applet {
    } {
	Add the static applet to dotlrn - for one-time init
	Must be repeatable!
    } {
        dotlrn_applet::add_applet_to_dotlrn \
                -applet_key [applet_key]
    }

    ad_proc -public add_applet_to_community {
	community_id
    } {
	Add the static applet to a dotlrn community
    } {
	# Create and Mount myself at /static under the community
	set instance_id [dotlrn::instantiate_and_mount \
                -mount_point "static" $community_id [package_key]]

        # We don't want to add a portlet until one is created by the static portlet admin (ben)
#  	# get the portal_template_id by callback
#  	set pt_id [dotlrn_community::get_portal_template_id $community_id]

#  	# set up the DS for the portal template
#  	static_portlet::make_self_available $pt_id
#  	static_portlet::add_self_to_page $pt_id $instance_id

        # set up the DS for the admin page
        set admin_portal_id \
                [dotlrn_community::get_community_admin_portal_id $community_id]
        static_admin_portlet::make_self_available $admin_portal_id
        static_admin_portlet::add_self_to_page $admin_portal_id $instance_id

	# FIXME aks - perms?

	# return the instance_id
	return $instance_id
    }

    ad_proc -public remove_applet {
	community_id
	package_id
    } {
	remove the applet from the community
    } {
	# Remove all instances of the static portlet!
	# Killing the package
    }

    ad_proc -public add_user {
	community_id
    } {
	Called when the user is initially added as a dotlrn user.
	For one-time init stuff
	
    } {
	
    }


    ad_proc -public add_user_to_community {
	community_id
	user_id
    } {
	Add a user to a specific dotlrn community
    } {
        # This needs to loop through all content items for this community
        # and add them to the user's portlet
        # FIXME
    }

    ad_proc -public remove_user {
        user_id
    } {
    } {
    }

    ad_proc -public remove_user_from_community {
	community_id
	user_id
    } {
	Remove a user from a community
    } {
        # Remove all static_portlet instances from the user-community portal
        # FIXME
    }
}
