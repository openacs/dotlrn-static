#
#  Copyright (C) 2001, 2002 OpenForce, Inc.
#
#  This file is part of dotLRN.
#
#  dotLRN is free software; you can redistribute it and/or modify it under the
#  terms of the GNU General Public License as published by the Free Software
#  Foundation; either version 2 of the License, or (at your option) any later
#  version.
#
#  dotLRN is distributed in the hope that it will be useful, but WITHOUT ANY
#  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
#  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
#  details.
#

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
        # FIXME: won't work with multiple dotlrn instances
        # aks - trying one mounting of static under /dotlrn (like calendar)
        # Use the package_key for the -url param - "/" are not allowed!
        if {![dotlrn::is_package_mounted -package_key [my_package_key]]} {
            dotlrn_applet::mount  -package_key [package_key]
        }

        dotlrn_applet::add_applet_to_dotlrn -applet_key [applet_key]
    }

    ad_proc -public add_applet_to_community {
	community_id
    } {
	Add the static applet to a dotlrn community
    } {
        set community_type \
                [dotlrn_community::get_community_type_from_community_id $community_id]

        set pt_id [dotlrn_community::get_portal_template_id $community_id]

        ns_log notice "aks7: $pt_id"

        # If i'm in a class, add a portlet called "class (pn) info"
        # if I'm in a community, add a portlet called "community (pn) info"
        # or if I'm in a subcomm, "subcomm (pn) info"
        if {$community_type == "dotlrn_club"} {
            set content_id [static_portal_content::new \
                    -instance_id $community_id \
                    -content " " \
                    -pretty_name "[dotlrn::parameter clubs_pretty_name] Info"
            ]
        
            static_portal_content::add_to_portal \
                    -content_id $content_id \
                    -portal_id $pt_id
    
        } elseif {$community_type == "dotlrn_community"} {

            set content_id [static_portal_content::new \
                    -instance_id $community_id \
                    -content " " \
                    -pretty_name "[dotlrn::parameter subcommunities_pretty_name] Info"
            ]
        
            static_portal_content::add_to_portal \
                    -content_id $content_id \
                    -portal_id $pt_id                
        } else {
            set content_id [static_portal_content::new \
                    -instance_id $community_id \
                    -content " " \
                    -pretty_name "[dotlrn::parameter class_instances_pretty_name] Info"
            ]
        
            static_portal_content::add_to_portal \
                    -content_id $content_id \
                    -portal_id $pt_id
        } 

        if {[dotlrn_community::dummy_comm_p -community_id $community_id]} {
            return
        }

        # the non-member page gets the same static portlet
        set n_p_id [dotlrn_community::get_community_non_members_portal_id $community_id]

        static_portal_content::add_to_portal \
                -content_id $content_id \
                -portal_id $n_p_id

        # set up the DS for the admin page
        set admin_portal_id \
                [dotlrn_community::get_community_admin_portal_id $community_id]
        static_admin_portlet::make_self_available $admin_portal_id
        static_admin_portlet::add_self_to_page $admin_portal_id $community_id

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
